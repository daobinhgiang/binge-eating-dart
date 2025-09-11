// This is a basic Flutter widget test for the BED Support App.

import 'package:flutter_test/flutter_test.dart';

import 'package:bed_app_1/models/user_model.dart';
import 'package:bed_app_1/core/utils/validators.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should create instance with required fields', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.patient,
        createdAt: DateTime.now(),
      );

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, UserRole.patient);
      expect(user.fullName, 'John Doe');
    });

    test('UserModel copyWith should work correctly', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.patient,
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        firstName: 'Jane',
        role: UserRole.clinician,
      );

      expect(updatedUser.firstName, 'Jane');
      expect(updatedUser.lastName, 'Doe'); // Should remain unchanged
      expect(updatedUser.role, UserRole.clinician);
      expect(updatedUser.email, 'test@example.com'); // Should remain unchanged
    });
  });

  group('Validators Tests', () {
    test('Email validation should work correctly', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.uk'), null);
    });

    test('Password validation should work correctly', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('123'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('password'), 'Password must contain at least one number');
      expect(Validators.validatePassword('123456'), 'Password must contain at least one letter');
      expect(Validators.validatePassword('pass123'), null);
    });

    test('Name validation should work correctly', () {
      expect(Validators.validateFirstName(''), 'First name is required');
      expect(Validators.validateFirstName('A'), 'First name must be at least 2 characters long');
      expect(Validators.validateFirstName('John123'), 'First name can only contain letters, spaces, hyphens, and apostrophes');
      expect(Validators.validateFirstName('John'), null);
      expect(Validators.validateFirstName("O'Connor"), null);
    });

    test('Confirm password validation should work correctly', () {
      expect(Validators.validateConfirmPassword('', 'password'), 'Please confirm your password');
      expect(Validators.validateConfirmPassword('different', 'password'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('password', 'password'), null);
    });
  });

  group('UserRole Tests', () {
    test('UserRole displayName should work correctly', () {
      expect(UserRole.patient.displayName, 'Patient');
      expect(UserRole.clinician.displayName, 'Clinician');
    });
  });
}
