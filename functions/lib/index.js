"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Initialize Firebase Admin
admin.initializeApp();
// Clean slate - ready for new Firebase functions and Google Cloud Scheduler integration