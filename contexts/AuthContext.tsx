import React, { createContext, useContext, useState, useEffect } from 'react';
import * as SecureStore from 'expo-secure-store';

interface Driver {
  id: string;
  username: string;
  name?: string;
  email?: string;
  phone?: string;
  status?: string;
}

interface AuthContextType {
  isAuthenticated: boolean;
  currentDriver: Driver | null;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  getStoredToken: () => Promise<string | null>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentDriver, setCurrentDriver] = useState<Driver | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const baseURL = process.env.EXPO_PUBLIC_API_URL;

  useEffect(() => {
    checkAuthenticationStatus();
  }, []);

  const checkAuthenticationStatus = async () => {
    try {
      const token = await SecureStore.getItemAsync('jwt_token');
      if (token) {
        setIsAuthenticated(true);
        // You might want to validate the token with the server here
      }
    } catch (error) {
      console.error('Error checking auth status:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (username: string, password: string) => {
    try {
      const response = await fetch(`${baseURL}/driver/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();

      if (response.ok) {
        await SecureStore.setItemAsync('jwt_token', data.token);
        setCurrentDriver(data.driver);
        setIsAuthenticated(true);
        return { success: true };
      } else {
        return { success: false, error: data.message || 'Login failed' };
      }
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  };

  const logout = async () => {
    try {
      await SecureStore.deleteItemAsync('jwt_token');
      setIsAuthenticated(false);
      setCurrentDriver(null);
    } catch (error) {
      console.error('Error during logout:', error);
    }
  };

  const getStoredToken = async () => {
    try {
      return await SecureStore.getItemAsync('jwt_token');
    } catch (error) {
      console.error('Error getting token:', error);
      return null;
    }
  };

  const value = {
    isAuthenticated,
    currentDriver,
    isLoading,
    login,
    logout,
    getStoredToken,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};