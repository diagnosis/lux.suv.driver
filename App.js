import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { AuthProvider } from './src/context/AuthContext';
import { RideProvider } from './src/context/RideContext';
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  return (
    <AuthProvider>
      <RideProvider>
        <NavigationContainer>
          <StatusBar style="light" backgroundColor="#0D0D1A" />
          <AppNavigator />
        </NavigationContainer>
      </RideProvider>
    </AuthProvider>
  );
}