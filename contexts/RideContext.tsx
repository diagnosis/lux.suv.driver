import React, { createContext, useContext, useState } from 'react';
import { useAuth } from './AuthContext';

interface Ride {
  id: string;
  name?: string;
  email?: string;
  phoneNumber?: string;
  rideType?: string;
  pickup: string;
  dropoff: string;
  date: string;
  time: string;
  numberOfPassengers?: number;
  numberOfLuggage?: number;
  additionalNotes?: string;
  status: string;
  fare?: number;
  distance?: number;
  duration?: number;
}

interface RideContextType {
  rides: Ride[];
  isLoading: boolean;
  errorMessage: string | null;
  fetchRides: () => Promise<void>;
  updateRide: (id: string, status: string, notes?: string) => Promise<boolean>;
  deleteRide: (id: string) => Promise<boolean>;
  ridesForDate: (date: Date) => Ride[];
  upcomingRides: () => Ride[];
}

const RideContext = createContext<RideContextType | undefined>(undefined);

export const useRides = () => {
  const context = useContext(RideContext);
  if (!context) {
    throw new Error('useRides must be used within a RideProvider');
  }
  return context;
};

export const RideProvider = ({ children }: { children: React.ReactNode }) => {
  const [rides, setRides] = useState<Ride[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  
  const { getStoredToken } = useAuth();
  const baseURL = process.env.EXPO_PUBLIC_API_URL;

  const fetchRides = async () => {
    const token = await getStoredToken();
    if (!token) {
      setErrorMessage('No authentication token found');
      return;
    }

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const response = await fetch(`${baseURL}/driver/book-rides`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('API Response Status:', response.status);

      if (response.ok) {
        const data = await response.json();
        console.log('Raw API Response:', JSON.stringify(data, null, 2));

        // Parse the API response format
        const convertedRides = data.map((apiRide: any) => ({
          id: String(apiRide.id),
          name: apiRide.your_name,
          email: apiRide.email,
          phoneNumber: apiRide.phone_number,
          rideType: apiRide.ride_type,
          pickup: apiRide.pickup_location,
          dropoff: apiRide.dropoff_location,
          date: apiRide.date,
          time: apiRide.time,
          numberOfPassengers: apiRide.number_of_passengers,
          numberOfLuggage: apiRide.number_of_luggage,
          additionalNotes: apiRide.additional_notes,
          status: 'requested', // Default status
          fare: null,
          distance: null,
          duration: null,
        }));

        setRides(convertedRides);
        console.log('✅ Successfully parsed', convertedRides.length, 'rides from API');
      } else {
        const errorData = await response.json();
        setErrorMessage(errorData.message || 'Failed to fetch rides');
      }
    } catch (error: any) {
      console.error('❌ Network error:', error);
      setErrorMessage(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  const updateRide = async (id: string, status: string, notes?: string) => {
    const token = await getStoredToken();
    if (!token) {
      setErrorMessage('No authentication token found');
      return false;
    }

    try {
      const response = await fetch(`${baseURL}/driver/book-ride/${id}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status, notes }),
      });

      if (response.ok) {
        await fetchRides(); // Refresh rides
        return true;
      } else {
        const errorData = await response.json();
        setErrorMessage(errorData.message || 'Failed to update ride');
        return false;
      }
    } catch (error: any) {
      setErrorMessage(error.message);
      return false;
    }
  };

  const deleteRide = async (id: string) => {
    const token = await getStoredToken();
    if (!token) {
      setErrorMessage('No authentication token found');
      return false;
    }

    try {
      const response = await fetch(`${baseURL}/driver/book-ride/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        await fetchRides(); // Refresh rides
        return true;
      } else {
        const errorData = await response.json();
        setErrorMessage(errorData.message || 'Failed to delete ride');
        return false;
      }
    } catch (error: any) {
      setErrorMessage(error.message);
      return false;
    }
  };

  // Helper functions
  const ridesForDate = (date: Date) => {
    const targetDate = date.toISOString().split('T')[0]; // YYYY-MM-DD format
    return rides.filter(ride => ride.date === targetDate);
  };

  const upcomingRides = () => {
    const now = new Date();
    return rides
      .filter(ride => {
        const rideDateTime = new Date(`${ride.date} ${ride.time}`);
        return rideDateTime > now && (ride.status === 'requested' || ride.status === 'accepted');
      })
      .sort((a, b) => {
        const dateA = new Date(`${a.date} ${a.time}`);
        const dateB = new Date(`${b.date} ${b.time}`);
        return dateA.getTime() - dateB.getTime();
      });
  };

  const value = {
    rides,
    isLoading,
    errorMessage,
    fetchRides,
    updateRide,
    deleteRide,
    ridesForDate,
    upcomingRides,
  };

  return <RideContext.Provider value={value}>{children}</RideContext.Provider>;
};