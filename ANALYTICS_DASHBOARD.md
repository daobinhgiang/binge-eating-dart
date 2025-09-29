# 📊 Analytics Dashboard Guide

## 🎯 **Key Metrics to Monitor**

### **Critical User Engagement**
- **`urge_relapse_button_clicked`** - Most important metric
  - **Frequency**: How often users need help
  - **Time patterns**: When users are most vulnerable
  - **User segments**: Which users need more support

### **Help Dialog Effectiveness**
- **`urge_help_dialog_interaction`** with actions:
  - `dialog_opened` - How many users open the help dialog
  - `dialog_closed` - How many users close without action
  - `urge_surfing_navigation` - How many users engage with coping tools

## 📈 **Firebase Console Setup**

### **1. Access Your Data**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `bed-app-ef8f8`
3. Navigate to **Analytics** → **Events**

### **2. Create Custom Dashboards**
1. Go to **Analytics** → **Custom Definitions** → **Custom Events**
2. Add your custom events:
   - `urge_relapse_button_clicked`
   - `urge_help_dialog_interaction`
   - `crisis_moment`
   - `app_usage_pattern`

### **3. Set Up Alerts**
1. Go to **Analytics** → **Audiences**
2. Create audience for "High Risk Users":
   - Users who clicked urge-relapse button > 3 times in 7 days
   - Users who opened help dialog but didn't engage with tools

## 🚨 **Critical Alerts to Set Up**

### **Crisis Detection**
```javascript
// Firebase Analytics Alert
Event: urge_relapse_button_clicked
Condition: Count > 5 in 1 hour
Action: Send notification to support team
```

### **Engagement Drop-off**
```javascript
// Firebase Analytics Alert  
Event: urge_help_dialog_interaction
Action: dialog_opened
Condition: No follow-up action within 2 minutes
Action: Trigger in-app reminder
```

## 📊 **Recommended Reports**

### **Daily Reports**
1. **Urge-relapse button usage by hour**
2. **Help dialog engagement rate**
3. **User retention by day**

### **Weekly Reports**
1. **High-risk user identification**
2. **Feature usage patterns**
3. **User journey analysis**

### **Monthly Reports**
1. **Overall app health metrics**
2. **User behavior trends**
3. **Intervention effectiveness**

## 🔧 **Advanced Analytics Setup**

### **User Properties to Track**
- `onboarding_completed`: Boolean
- `user_risk_level`: String (low, medium, high)
- `preferred_coping_method`: String
- `last_crisis_date`: Date

### **Custom Events to Add**
- `crisis_moment`: When users are in distress
- `coping_tool_used`: When users engage with tools
- `support_contacted`: When users reach out for help
- `milestone_achieved`: When users reach recovery milestones

## 📱 **Real-time Monitoring**

### **Firebase Console Real-time**
1. Go to **Analytics** → **Real-time**
2. Monitor live events as they happen
3. Set up real-time alerts for crisis moments

### **Google Analytics 4 Integration**
1. Link Firebase to GA4 using your `measurementId`
2. Access advanced reporting in GA4
3. Create custom reports and dashboards

## 🎯 **Success Metrics**

### **Primary KPIs**
- **Crisis Prevention Rate**: % of users who don't relapse after using help
- **Tool Engagement Rate**: % of users who engage with coping tools
- **Support Utilization**: % of users who use help features

### **Secondary KPIs**
- **App Retention**: Daily/Weekly/Monthly active users
- **Feature Adoption**: % of users using each feature
- **User Satisfaction**: Based on engagement patterns

## 🚀 **Next Steps**

1. **Test the integration** using the test script
2. **Set up Firebase Console** dashboards
3. **Configure alerts** for critical events
4. **Monitor for 1 week** to establish baselines
5. **Create custom reports** based on your needs
6. **Set up automated reports** for stakeholders

## 📞 **Support Resources**

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Google Analytics 4 Documentation](https://developers.google.com/analytics/devguides/collection/ga4)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Analytics](https://analytics.google.com/)
