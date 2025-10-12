class FoodDatabase {
  static const List<String> foods = [
    // Fruits
    'Apple', 'Banana', 'Orange', 'Grape', 'Strawberry', 'Blueberry', 'Raspberry', 'Blackberry',
    'Pineapple', 'Mango', 'Kiwi', 'Peach', 'Pear', 'Plum', 'Cherry', 'Watermelon', 'Cantaloupe',
    'Grapefruit', 'Lemon', 'Lime', 'Avocado', 'Coconut', 'Pomegranate', 'Cranberry',
    
    // Vegetables
    'Broccoli', 'Carrot', 'Spinach', 'Lettuce', 'Tomato', 'Cucumber', 'Bell Pepper', 'Onion',
    'Garlic', 'Potato', 'Sweet Potato', 'Corn', 'Peas', 'Green Beans', 'Asparagus', 'Cauliflower',
    'Cabbage', 'Celery', 'Radish', 'Beet', 'Mushroom', 'Zucchini', 'Eggplant', 'Artichoke',
    
    // Proteins
    'Chicken Breast', 'Chicken Thigh', 'Ground Beef', 'Steak', 'Pork Chop', 'Bacon', 'Ham',
    'Turkey Breast', 'Salmon', 'Tuna', 'Cod', 'Shrimp', 'Crab', 'Lobster', 'Eggs', 'Tofu',
    'Tempeh', 'Beans', 'Lentils', 'Chickpeas', 'Quinoa', 'Greek Yogurt', 'Cottage Cheese',
    
    // Grains & Breads
    'White Rice', 'Brown Rice', 'Quinoa', 'Oats', 'Barley', 'Bulgur', 'White Bread', 'Whole Wheat Bread',
    'Bagel', 'English Muffin', 'Tortilla', 'Pita Bread', 'Crackers', 'Pasta', 'Noodles',
    
    // Dairy
    'Milk', 'Cheese', 'Cheddar Cheese', 'Mozzarella', 'Parmesan', 'Cream Cheese', 'Butter',
    'Yogurt', 'Greek Yogurt', 'Cottage Cheese', 'Sour Cream', 'Ice Cream', 'Cream',
    
    // Nuts & Seeds
    'Almonds', 'Walnuts', 'Pecans', 'Cashews', 'Pistachios', 'Peanuts', 'Sunflower Seeds',
    'Pumpkin Seeds', 'Chia Seeds', 'Flax Seeds', 'Sesame Seeds', 'Hazelnuts', 'Macadamia Nuts',
    
    // Beverages
    'Water', 'Coffee', 'Tea', 'Green Tea', 'Black Tea', 'Orange Juice', 'Apple Juice',
    'Cranberry Juice', 'Grape Juice', 'Soda', 'Diet Soda', 'Energy Drink', 'Sports Drink',
    'Beer', 'Wine', 'Cocktail', 'Smoothie', 'Protein Shake', 'Milkshake',
    
    // Snacks & Sweets
    'Chips', 'Popcorn', 'Pretzels', 'Crackers', 'Cookies', 'Cake', 'Pie', 'Chocolate',
    'Dark Chocolate', 'Candy', 'Gummy Bears', 'Ice Cream', 'Frozen Yogurt', 'Pudding',
    'Jelly', 'Jam', 'Honey', 'Maple Syrup', 'Sugar', 'Brown Sugar',
    
    // Condiments & Sauces
    'Ketchup', 'Mustard', 'Mayonnaise', 'Ranch Dressing', 'Italian Dressing', 'Caesar Dressing',
    'BBQ Sauce', 'Hot Sauce', 'Soy Sauce', 'Teriyaki Sauce', 'Olive Oil', 'Vegetable Oil',
    'Vinegar', 'Balsamic Vinegar', 'Salt', 'Pepper', 'Garlic Powder', 'Onion Powder',
    
    // Fast Food
    'Hamburger', 'Cheeseburger', 'French Fries', 'Chicken Nuggets', 'Pizza', 'Taco',
    'Burrito', 'Sandwich', 'Sub', 'Hot Dog', 'Fried Chicken', 'Fish and Chips',
    
    // Breakfast Items
    'Cereal', 'Oatmeal', 'Pancakes', 'Waffles', 'French Toast', 'Scrambled Eggs',
    'Fried Eggs', 'Omelet', 'Hash Browns', 'Toast', 'Muffin', 'Croissant',
    
    // Soups & Salads
    'Chicken Soup', 'Tomato Soup', 'Vegetable Soup', 'Caesar Salad', 'Garden Salad',
    'Cobb Salad', 'Greek Salad', 'Coleslaw', 'Potato Salad', 'Pasta Salad',
    
    // International Foods
    'Sushi', 'Ramen', 'Stir Fry', 'Curry', 'Pad Thai', 'Sushi Roll', 'Dumplings',
    'Spring Rolls', 'Falafel', 'Hummus', 'Guacamole', 'Salsa', 'Pico de Gallo',
    
    // Frozen Foods
    'Frozen Pizza', 'Frozen Vegetables', 'Frozen Fruit', 'Frozen Yogurt', 'Frozen Dinner',
    'Frozen Waffles', 'Frozen Burrito', 'Frozen Lasagna',
    
    // Canned Foods
    'Canned Tuna', 'Canned Salmon', 'Canned Beans', 'Canned Tomatoes', 'Canned Corn',
    'Canned Soup', 'Canned Fruit', 'Canned Vegetables',
  ];

  static List<String> searchFoods(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return foods
        .where((food) => food.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  static List<String> getPopularFoods() {
    return [
      'Chicken Breast', 'Salmon', 'Rice', 'Broccoli', 'Apple', 'Banana',
      'Greek Yogurt', 'Eggs', 'Spinach', 'Almonds', 'Water', 'Coffee'
    ];
  }
}
