import '../models/article.dart';

class SampleData {
  static List<Article> getSampleArticles() {
    return [
      Article(
        id: '1',
        title: 'Understanding Binge Eating Disorder: A Comprehensive Guide',
        content: '''Binge Eating Disorder (BED) is a serious eating disorder characterized by recurrent episodes of eating large quantities of food, often very quickly and to the point of discomfort. Unlike other eating disorders, people with BED don't try to "undo" their excessive eating with extreme actions like purging or over-exercising.

Key characteristics of BED include:
• Eating unusually large amounts of food in a specific amount of time
• Feeling a loss of control during the episode
• Eating rapidly during binge episodes
• Eating until uncomfortably full
• Eating large amounts of food when not physically hungry
• Eating alone because of embarrassment about the amount of food being eaten
• Feeling disgusted, depressed, or guilty after overeating

BED affects people of all ages, genders, and backgrounds. It's the most common eating disorder in the United States, affecting approximately 2.8% of adults. The disorder often begins in late adolescence or early adulthood, but it can develop at any age.

Understanding that BED is a real medical condition, not a lack of willpower, is crucial for recovery. With proper treatment and support, recovery is absolutely possible.''',
        category: 'Understanding BED',
        author: 'Dr. Sarah Johnson',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['understanding', 'basics', 'symptoms', 'prevalence'],
        readTimeMinutes: 8,
        isFeatured: true,
      ),
      Article(
        id: '2',
        title: 'Coping Strategies for Difficult Moments',
        content: '''When you feel the urge to binge, having a toolkit of coping strategies can make all the difference. Here are some evidence-based techniques that can help you navigate challenging moments:

1. **The 5-4-3-2-1 Grounding Technique**
   - Name 5 things you can see
   - Name 4 things you can touch
   - Name 3 things you can hear
   - Name 2 things you can smell
   - Name 1 thing you can taste

2. **Mindful Breathing**
   - Take 10 deep breaths, counting to 4 on the inhale and 6 on the exhale
   - Focus entirely on your breathing

3. **Delay and Distract**
   - Set a timer for 15 minutes and engage in a different activity
   - Call a friend, take a walk, or do a puzzle

4. **Check in with Your Emotions**
   - Ask yourself: "What am I really feeling right now?"
   - Journal about your emotions instead of eating

5. **Use Your Senses**
   - Light a scented candle
   - Listen to calming music
   - Take a warm bath

Remember, these strategies take practice. It's okay if they don't work perfectly the first time. The goal is progress, not perfection.''',
        category: 'Coping Strategies',
        author: 'Lisa Chen, LCSW',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        tags: ['coping', 'mindfulness', 'grounding', 'distraction'],
        readTimeMinutes: 6,
        isFeatured: true,
      ),
      Article(
        id: '3',
        title: 'Building a Healthy Relationship with Food',
        content: '''Recovery from BED involves rebuilding your relationship with food. This doesn't mean perfect eating—it means developing a balanced, flexible approach to nutrition that supports both your physical and mental health.

**Key Principles:**

1. **Regular Eating Schedule**
   - Eat every 3-4 hours to maintain stable blood sugar
   - Include all three macronutrients: carbohydrates, proteins, and fats
   - Don't skip meals, as this can trigger binge episodes

2. **Mindful Eating Practices**
   - Eat without distractions (no TV, phone, or computer)
   - Chew slowly and savor each bite
   - Pay attention to hunger and fullness cues
   - Stop eating when you feel satisfied, not stuffed

3. **All Foods Fit**
   - No foods are "good" or "bad"
   - Include a variety of foods in your diet
   - Allow yourself to enjoy treats in moderation
   - Focus on adding nutritious foods rather than restricting

4. **Meal Planning and Preparation**
   - Plan meals ahead of time to reduce decision fatigue
   - Keep healthy snacks readily available
   - Prepare meals that you actually enjoy eating

5. **Professional Support**
   - Work with a registered dietitian who specializes in eating disorders
   - Consider working with a therapist who understands BED
   - Remember that recovery is a journey, not a destination''',
        category: 'Nutrition & Eating',
        author: 'Maria Rodriguez, RD',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['nutrition', 'mindful-eating', 'meal-planning', 'balance'],
        readTimeMinutes: 7,
        isFeatured: false,
      ),
      Article(
        id: '4',
        title: 'The Connection Between Emotions and Eating',
        content: '''Many people with BED use food as a way to cope with difficult emotions. Understanding this connection is a crucial step in recovery.

**Common Emotional Triggers:**
• Stress and anxiety
• Sadness and depression
• Loneliness
• Anger and frustration
• Boredom
• Feeling overwhelmed

**The Emotional Eating Cycle:**
1. You experience a difficult emotion
2. You feel uncomfortable and want to escape
3. You turn to food for comfort or distraction
4. You eat more than intended
5. You feel guilty and ashamed
6. The cycle repeats

**Breaking the Cycle:**

1. **Identify Your Triggers**
   - Keep a mood and food journal
   - Notice patterns between emotions and eating
   - Look for specific situations that trigger binges

2. **Develop Alternative Coping Strategies**
   - Exercise or physical activity
   - Creative outlets (art, music, writing)
   - Social connection with friends or family
   - Relaxation techniques (meditation, yoga)

3. **Practice Emotional Regulation**
   - Learn to sit with difficult emotions
   - Use breathing exercises
   - Practice self-compassion
   - Seek professional help when needed

Remember: It's okay to feel difficult emotions. The goal isn't to never feel sad, angry, or stressed—it's to develop healthier ways of coping with these feelings.''',
        category: 'Mental Health',
        author: 'Dr. Michael Thompson',
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
        tags: ['emotions', 'triggers', 'coping', 'emotional-regulation'],
        readTimeMinutes: 9,
        isFeatured: false,
      ),
      Article(
        id: '5',
        title: 'Building Your Support System',
        content: '''Recovery from BED doesn't happen in isolation. Building a strong support system is essential for long-term success.

**Types of Support You Might Need:**

1. **Professional Support**
   - Therapist or counselor specializing in eating disorders
   - Registered dietitian
   - Primary care physician
   - Psychiatrist (if medication is needed)

2. **Peer Support**
   - Support groups for people with eating disorders
   - Online communities (be careful to choose supportive, recovery-focused groups)
   - Friends who understand your journey

3. **Family and Friends**
   - Loved ones who are educated about BED
   - People who can provide emotional support
   - Those who can help with practical aspects of recovery

**How to Build Your Support System:**

1. **Educate Your Loved Ones**
   - Share information about BED
   - Explain what you need from them
   - Set boundaries around food and body talk

2. **Find Professional Help**
   - Look for providers with eating disorder experience
   - Don't be afraid to "shop around" for the right fit
   - Consider both individual and group therapy

3. **Join Support Groups**
   - Look for local or online support groups
   - Consider both general eating disorder groups and BED-specific groups
   - Remember that everyone's recovery journey is different

4. **Practice Self-Advocacy**
   - Learn to ask for what you need
   - Set boundaries with people who aren't supportive
   - Remember that you deserve help and support

**Remember:** Recovery is not a linear process, and having support makes the journey much more manageable. Don't be afraid to reach out for help when you need it.''',
        category: 'Support & Resources',
        author: 'Jennifer Walsh, LPC',
        publishedAt: DateTime.now().subtract(const Duration(days: 12)),
        tags: ['support', 'therapy', 'community', 'self-advocacy'],
        readTimeMinutes: 8,
        isFeatured: false,
      ),
      Article(
        id: '6',
        title: 'Recovery Milestones: Celebrating Your Progress',
        content: '''Recovery from BED is a journey with many ups and downs. It's important to recognize and celebrate your progress, no matter how small it may seem.

**Common Recovery Milestones:**

1. **Early Stage**
   - Recognizing that you have a problem
   - Seeking help for the first time
   - Going one day without a binge episode
   - Being honest with a healthcare provider

2. **Middle Stage**
   - Going a week without binging
   - Identifying your triggers
   - Developing new coping strategies
   - Eating regular meals consistently

3. **Later Stage**
   - Going a month without binging
   - Feeling more comfortable around food
   - Having more good days than difficult ones
   - Helping others in their recovery

**How to Track Your Progress:**

1. **Keep a Recovery Journal**
   - Write down your daily experiences
   - Note what strategies worked
   - Celebrate small victories
   - Learn from setbacks

2. **Set Realistic Goals**
   - Focus on process goals, not outcome goals
   - Break large goals into smaller steps
   - Be flexible and adjust as needed

3. **Practice Self-Compassion**
   - Be kind to yourself during difficult times
   - Remember that setbacks are part of recovery
   - Celebrate your efforts, not just your results

**Remember:** Recovery is not about perfection. It's about progress, learning, and growing. Every step forward, no matter how small, is worth celebrating.''',
        category: 'Recovery Journey',
        author: 'Dr. Amanda Foster',
        publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        tags: ['recovery', 'milestones', 'progress', 'self-compassion'],
        readTimeMinutes: 6,
        isFeatured: true,
      ),
    ];
  }
}

