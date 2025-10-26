    import * as functions from 'firebase-functions';
    import * as admin from 'firebase-admin';
    import * as crypto from 'crypto';

    /**
     * Superwall Webhook Handler
     * 
     * Handles subscription events from Superwall and updates user premium status in Firestore.
     * 
     * Webhook Events:
     * - subscription_start: User started a new subscription
     * - transaction_complete: User completed a purchase transaction
     * - subscription_renew: User's subscription renewed
     * - subscription_cancel: User cancelled their subscription
     * - subscription_expire: User's subscription expired
     * 
     * Security:
     * - Validates webhook signature using Superwall secret
     * - Logs all events for debugging
     * 
     * Environment Variables Required:
     * - SUPERWALL_WEBHOOK_SECRET: Secret key from Superwall dashboard
     */

    interface SuperwallWebhookPayload {
    event_name: string;
    app_user_id: string;
    event_created_at: string;
    aliases?: string[];
    subscriber_attributes?: Record<string, any>;
    product_id?: string;
    period_type?: string;
    purchased_at?: string;
    expiration_at?: string;
    store?: string;
    environment?: string;
    }

    // Webhook endpoint
    export const superwallWebhook = functions.https.onRequest(async (req, res) => {
    console.log('═══════════════════════════════════════════════════════════');
    console.log('🔔 SUPERWALL WEBHOOK RECEIVED');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
    console.log(`📍 Method: ${req.method}`);
    console.log(`🌐 IP: ${req.ip}`);
    
    try {
        // Only accept POST requests
        if (req.method !== 'POST') {
        console.log('❌ Invalid method - only POST allowed');
        res.status(405).send('Method Not Allowed');
        return;
        }

        // Get webhook secret from environment
        const webhookSecret = functions.config().superwall?.webhook_secret || process.env.SUPERWALL_WEBHOOK_SECRET;
        
        if (!webhookSecret) {
        console.error('❌ SUPERWALL_WEBHOOK_SECRET not configured');
        res.status(500).send('Webhook secret not configured');
        return;
        }

        // Verify webhook signature (if Superwall provides one)
        const signature = req.headers['x-superwall-signature'] as string;
        if (signature) {
        const isValid = verifyWebhookSignature(req.body, signature, webhookSecret);
        if (!isValid) {
            console.error('❌ Invalid webhook signature');
            res.status(401).send('Invalid signature');
            return;
        }
        console.log('✅ Webhook signature verified');
        } else {
        console.log('⚠️ No signature provided - proceeding without verification');
        }

        // Parse webhook payload
        const payload: SuperwallWebhookPayload = req.body;
        
        console.log('📦 Webhook Payload:');
        console.log(`   Event: ${payload.event_name}`);
        console.log(`   User ID: ${payload.app_user_id}`);
        console.log(`   Product: ${payload.product_id || 'N/A'}`);
        console.log(`   Store: ${payload.store || 'N/A'}`);
        console.log(`   Environment: ${payload.environment || 'N/A'}`);

        // Handle different event types
        await handleWebhookEvent(payload);

        console.log('✅ Webhook processed successfully');
        console.log('═══════════════════════════════════════════════════════════');
        
        res.status(200).send('OK');
    } catch (error) {
        console.error('❌ Error processing webhook:', error);
        console.error('   Stack:', error instanceof Error ? error.stack : 'N/A');
        console.log('═══════════════════════════════════════════════════════════');
        
        // Return 200 to prevent Superwall from retrying on our internal errors
        // Log the error but acknowledge receipt
        res.status(200).send('Error logged');
    }
    });

    /**
     * Verify webhook signature using HMAC-SHA256
     */
    function verifyWebhookSignature(payload: any, signature: string, secret: string): boolean {
    try {
        const payloadString = typeof payload === 'string' ? payload : JSON.stringify(payload);
        const hmac = crypto.createHmac('sha256', secret);
        hmac.update(payloadString);
        const expectedSignature = hmac.digest('hex');
        
        // Use timing-safe comparison
        return crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expectedSignature)
        );
    } catch (error) {
        console.error('Error verifying signature:', error);
        return false;
    }
    }

    /**
     * Handle different webhook event types
     */
    async function handleWebhookEvent(payload: SuperwallWebhookPayload): Promise<void> {
    const { event_name, app_user_id } = payload;

    // Map of events that should grant premium access
    const premiumGrantEvents = [
        'subscription_start',
        'transaction_complete',
        'subscription_renew',
        'trial_start',
    ];

    // Map of events that should revoke premium access
    const premiumRevokeEvents = [
        'subscription_cancel',
        'subscription_expire',
        'billing_issue',
    ];

    if (premiumGrantEvents.includes(event_name)) {
        console.log(`💎 Premium access event detected: ${event_name}`);
        await updateUserPremiumStatus(app_user_id, true, payload);
    } else if (premiumRevokeEvents.includes(event_name)) {
        console.log(`🔓 Premium revoke event detected: ${event_name}`);
        await updateUserPremiumStatus(app_user_id, false, payload);
    } else {
        console.log(`ℹ️ Event ${event_name} does not affect premium status`);
        // Still log the event for analytics
        await logSubscriptionEvent(app_user_id, payload);
    }
    }

    /**
     * Update user's premium status in Firestore
     */
    async function updateUserPremiumStatus(
    userId: string,
    isPremium: boolean,
    payload: SuperwallWebhookPayload
    ): Promise<void> {
    try {
        console.log(`🔄 Updating user ${userId} premium status to: ${isPremium}`);

        const userRef = admin.firestore().collection('users').doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
        console.error(`❌ User ${userId} not found in Firestore`);
        throw new Error(`User ${userId} not found`);
        }

        // Update user document
        const updateData: any = {
        isPremium: isPremium,
        lastSubscriptionUpdate: admin.firestore.FieldValue.serverTimestamp(),
        subscriptionStore: payload.store || null,
        subscriptionProductId: payload.product_id || null,
        };

        // Add subscription dates if available
        if (payload.purchased_at) {
        updateData.subscriptionStartedAt = new Date(payload.purchased_at).getTime();
        }
        if (payload.expiration_at) {
        updateData.subscriptionExpiresAt = new Date(payload.expiration_at).getTime();
        }

        await userRef.update(updateData);

        console.log(`✅ User ${userId} updated successfully`);
        console.log(`   isPremium: ${isPremium}`);
        console.log(`   Product: ${payload.product_id || 'N/A'}`);
        console.log(`   Store: ${payload.store || 'N/A'}`);

        // Log the subscription event
        await logSubscriptionEvent(userId, payload);

    } catch (error) {
        console.error(`❌ Error updating user ${userId}:`, error);
        throw error;
    }
    }

    /**
     * Log subscription event to a subcollection for analytics and debugging
     */
    async function logSubscriptionEvent(
    userId: string,
    payload: SuperwallWebhookPayload
    ): Promise<void> {
    try {
        const eventRef = admin.firestore()
        .collection('users')
        .doc(userId)
        .collection('subscription_events')
        .doc();

        await eventRef.set({
        eventName: payload.event_name,
        eventCreatedAt: payload.event_created_at,
        productId: payload.product_id || null,
        periodType: payload.period_type || null,
        purchasedAt: payload.purchased_at || null,
        expirationAt: payload.expiration_at || null,
        store: payload.store || null,
        environment: payload.environment || null,
        aliases: payload.aliases || [],
        subscriberAttributes: payload.subscriber_attributes || {},
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        rawPayload: payload,
        });

        console.log(`📝 Subscription event logged for user ${userId}`);
    } catch (error) {
        console.error(`⚠️ Error logging subscription event:`, error);
        // Don't throw - logging failure shouldn't fail the webhook
    }
    }

    /**
     * Manual function to update a user's premium status
     * Can be called directly from Firebase Console for testing/admin purposes
     */
    export const updateUserPremium = functions.https.onCall(async (data, context) => {
    // Verify the request is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Only allow admins/clinicians to manually update premium status
    const callerUid = context.auth.uid;
    const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
    const callerRole = callerDoc.data()?.role;

    if (callerRole !== 'clinician') {
        throw new functions.https.HttpsError(
        'permission-denied',
        'Only clinicians can manually update premium status'
        );
    }

    const { userId, isPremium } = data;

    if (!userId || typeof isPremium !== 'boolean') {
        throw new functions.https.HttpsError('invalid-argument', 'userId and isPremium are required');
    }

    try {
        console.log(`👨‍⚕️ Manual premium update by ${callerUid} for user ${userId}: ${isPremium}`);

        await admin.firestore().collection('users').doc(userId).update({
        isPremium: isPremium,
        lastSubscriptionUpdate: admin.firestore.FieldValue.serverTimestamp(),
        manuallyUpdatedBy: callerUid,
        });

        console.log(`✅ Manual update successful`);

        return { success: true, userId, isPremium };
    } catch (error) {
        console.error(`❌ Manual update failed:`, error);
        throw new functions.https.HttpsError('internal', 'Failed to update premium status');
    }
    });

