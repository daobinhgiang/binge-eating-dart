class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    
    if (!hasLetter) {
      return 'Password must contain at least one letter';
    }
    
    if (!hasNumber) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (trimmedValue.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // First name validation
  static String? validateFirstName(String? value) {
    return validateName(value, 'First name');
  }

  // Last name validation
  static String? validateLastName(String? value) {
    return validateName(value, 'Last name');
  }

  // Full name validation (for cases where first and last name are combined)
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Full name cannot be empty';
    }
    
    // Split by spaces and check if we have at least first and last name
    final nameParts = trimmedValue.split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length < 2) {
      return 'Please enter both first and last name';
    }
    
    if (nameParts.length > 5) {
      return 'Please enter a valid name (maximum 5 parts)';
    }
    
    // Validate each part
    for (final part in nameParts) {
      if (part.length < 2) {
        return 'Each name part must be at least 2 characters long';
      }
      
      if (part.length > 25) {
        return 'Each name part must be less than 25 characters';
      }
      
      final nameRegex = RegExp(r"^[a-zA-Z\-']+$");
      if (!nameRegex.hasMatch(part)) {
        return 'Name can only contain letters, hyphens, and apostrophes';
      }
    }
    
    return null;
  }

  // Phone number validation (optional for future use)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Age validation (for future use)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 13) {
      return 'You must be at least 13 years old to use this app';
    }
    
    if (age > 120) {
      return 'Please enter a valid age';
    }
    
    return null;
  }

  // Terms and conditions validation
  static String? validateTermsAndConditions(bool? value) {
    if (value != true) {
      return 'You must agree to the Terms of Service and Privacy Policy';
    }
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Generic non-empty validation
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  // Length validation
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null) return null;
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }
}
