import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../context/AuthContext';

export default function ProfileScreen() {
  const { currentDriver, logout } = useAuth();

  const handleLogout = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Sign Out', style: 'destructive', onPress: logout },
      ]
    );
  };

  const getProfileInitial = () => {
    if (currentDriver?.name) {
      return currentDriver.name.charAt(0).toUpperCase();
    } else if (currentDriver?.username) {
      return currentDriver.username.charAt(0).toUpperCase();
    }
    return 'D';
  };

  return (
    <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Profile</Text>
      </View>

      <View style={styles.content}>
        {/* Profile Header */}
        <View style={styles.profileHeader}>
          <LinearGradient
            colors={['#CDB649', '#E6CC52']}
            style={styles.avatarCircle}
          >
            <Text style={styles.avatarText}>{getProfileInitial()}</Text>
          </LinearGradient>

          <View style={styles.profileInfo}>
            <Text style={styles.profileName}>
              {currentDriver?.name || currentDriver?.username || 'Driver'}
            </Text>
            {currentDriver?.email && (
              <Text style={styles.profileEmail}>{currentDriver.email}</Text>
            )}
          </View>
        </View>

        <View style={styles.spacer} />

        {/* Profile Options */}
        <View style={styles.optionsContainer}>
          <ProfileOption
            icon="person-outline"
            title="Edit Profile"
            subtitle="Update your personal information"
            onPress={() => {
              // TODO: Navigate to edit profile
              Alert.alert('Coming Soon', 'Profile editing will be available soon');
            }}
          />

          <ProfileOption
            icon="settings-outline"
            title="Settings"
            subtitle="App preferences and notifications"
            onPress={() => {
              // TODO: Navigate to settings
              Alert.alert('Coming Soon', 'Settings will be available soon');
            }}
          />

          <ProfileOption
            icon="help-circle-outline"
            title="Help & Support"
            subtitle="Get help and contact support"
            onPress={() => {
              // TODO: Navigate to help
              Alert.alert('Coming Soon', 'Help section will be available soon');
            }}
          />

          <ProfileOption
            icon="information-circle-outline"
            title="About"
            subtitle="App version and information"
            onPress={() => {
              Alert.alert('LuxSUV Driver', 'Version 1.0.0\n\nPremium Transportation Service');
            }}
          />
        </View>

        <View style={styles.spacer} />

        {/* Logout Button */}
        <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
          <View style={styles.logoutButtonContent}>
            <Ionicons name="log-out-outline" size={18} color="#FFF" />
            <Text style={styles.logoutButtonText}>Sign Out</Text>
          </View>
        </TouchableOpacity>
      </View>
    </LinearGradient>
  );
}

const ProfileOption = ({ icon, title, subtitle, onPress }) => (
  <TouchableOpacity style={styles.optionCard} onPress={onPress}>
    <View style={styles.optionIcon}>
      <Ionicons name={icon} size={24} color="#CDB649" />
    </View>
    <View style={styles.optionContent}>
      <Text style={styles.optionTitle}>{title}</Text>
      <Text style={styles.optionSubtitle}>{subtitle}</Text>
    </View>
    <Ionicons name="chevron-forward" size={20} color="#9CA3AF" />
  </TouchableOpacity>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 20,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFF',
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  avatarCircle: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  avatarText: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#000',
  },
  profileInfo: {
    alignItems: 'center',
    gap: 4,
  },
  profileName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
  },
  profileEmail: {
    fontSize: 16,
    fontWeight: '500',
    color: '#D1D5DB',
  },
  spacer: {
    flex: 1,
  },
  optionsContainer: {
    gap: 12,
  },
  optionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 16,
    gap: 16,
  },
  optionIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(205, 182, 73, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  optionContent: {
    flex: 1,
    gap: 2,
  },
  optionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFF',
  },
  optionSubtitle: {
    fontSize: 14,
    fontWeight: '500',
    color: '#9CA3AF',
  },
  logoutButton: {
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(239, 68, 68, 0.5)',
    marginBottom: 40,
  },
  logoutButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    gap: 8,
  },
  logoutButtonText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFF',
  },
});