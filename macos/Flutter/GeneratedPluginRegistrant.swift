//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import cloud_firestore
import cloud_functions
import firebase_analytics
import firebase_auth
import firebase_core
import firebase_storage
import just_audio
import path_provider_foundation
import shared_preferences_foundation
import soundpool_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FLTFirebaseFunctionsPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFunctionsPlugin"))
  FLTFirebaseAnalyticsPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAnalyticsPlugin"))
  FLTFirebaseAuthPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAuthPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  FLTFirebaseStoragePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseStoragePlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SwiftSoundpoolPlugin.register(with: registry.registrar(forPlugin: "SwiftSoundpoolPlugin"))
}
