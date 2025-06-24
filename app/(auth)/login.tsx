import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Eye, EyeOff, Car, ArrowRight } from 'lucide-react-native';
import { useAuth } from '@/contexts/AuthContext';
import { router } from 'expo-router';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  
  const { login } = useAuth();

  const handleLogin = async () => {
    if (!username.trim() || !password.trim()) {
      Alert.alert('Error', 'Please enter both username and password');
      return;
    }

    setIsLoading(true);
    const result = await login(username.trim(), password);
    setIsLoading(false);

    if (result.success) {
      router.replace('/(tabs)');
    } else {
      Alert.alert('Login Failed', result.error);
    }
  };

  return (
    <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView contentContainerStyle={styles.scrollContent}>
          {/* Logo Section */}
          <View style={styles.logoSection}>
            <LinearGradient
              colors={['#CDB649', '#E6CC52']}
              style={styles.logoCircle}
            >
              <Car size={40} color="#000" />
            </LinearGradient>
            
            <Text style={styles.title}>LuxSUV Driver</Text>
            <Text style={styles.subtitle}>Premium Transportation Service</Text>
          </View>

          {/* Login Form */}
          <View style={styles.formSection}>
            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Username</Text>
              <View style={styles.inputWrapper}>
                <TextInput
                  style={styles.textInput}
                  placeholder="Enter your username"
                  placeholderTextColor="#6B7280"
                  value={username}
                  onChangeText={setUsername}
                  autoCapitalize="none"
                  autoCorrect={false}
                />
              </View>
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Password</Text>
              <View style={styles.inputWrapper}>
                <TextInput
                  style={[styles.textInput, { flex: 1 }]}
                  placeholder="Enter your password"
                  placeholderTextColor="#6B7280"
                  value={password}
                  onChangeText={setPassword}
                  secureTextEntry={!isPasswordVisible}
                />
                <TouchableOpacity
                  onPress={() => setIsPasswordVisible(!isPasswordVisible)}
                  style={styles.eyeButton}
                >
                  {isPasswordVisible ? (
                    <EyeOff size={20} color="#9CA3AF" />
                  ) : (
                    <Eye size={20} color="#9CA3AF" />
                  )}
                </TouchableOpacity>
              </View>
            </View>

            <TouchableOpacity
              style={[styles.loginButton, { opacity: isLoading ? 0.6 : 1 }]}
              onPress={handleLogin}
              disabled={isLoading}
            >
              <LinearGradient
                colors={['#CDB649', '#E6CC52']}
                style={styles.loginButtonGradient}
              >
                {isLoading ? (
                  <ActivityIndicator color="#000" />
                ) : (
                  <>
                    <ArrowRight size={18} color="#000" />
                    <Text style={styles.loginButtonText}>Sign In</Text>
                  </>
                )}
              </LinearGradient>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  keyboardView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  logoSection: {
    alignItems: 'center',
    marginBottom: 50,
  },
  logoCircle: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 10,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFF',
    marginBottom: 8,
    fontFamily: 'Inter-Bold',
  },
  subtitle: {
    fontSize: 16,
    color: '#D1D5DB',
    fontWeight: '500',
    fontFamily: 'Inter-Medium',
  },
  formSection: {
    gap: 24,
  },
  inputContainer: {
    gap: 8,
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#E5E7EB',
    fontFamily: 'Inter-SemiBold',
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  textInput: {
    flex: 1,
    color: '#FFF',
    fontSize: 16,
    fontFamily: 'Inter-Regular',
  },
  eyeButton: {
    padding: 4,
  },
  loginButton: {
    marginTop: 8,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  loginButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    borderRadius: 12,
    gap: 8,
  },
  loginButtonText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000',
    fontFamily: 'Inter-SemiBold',
  },
});