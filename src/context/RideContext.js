import React, { createContext, useContext, useState } from 'react';
import { useAuth } from './AuthContext';

const RideContext = createContext();

export const useRides = () => {
  const context = useContext(RideContext);
  if (!context) {
    throw new Error('useRides must be used within a RideProvider');
  }
  return context;
};

export const RideProvider = ({ children }) => {
  const [rides, setRides] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState(null);
  
  const { getStoredToken } = useAuth();
  const baseURL = 'https://luxsuv-backend.fly.dev';

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
        const convertedRides = data.map(apiRide => ({
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
    } catch (error) {
      console.error('❌ Network error:', error);
      setErrorMessage(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  const updateRide = async (id, status, notes = null) => {
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
    } catch (error) {
      setErrorMessage(error.message);
      return false;
    }
  };

  const deleteRide = async (id) => {
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
    } catch (error) {
      setErrorMessage(error.message);
      return false;
    }
  };

  // Helper functions
  const ridesForDate = (date) => {
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
        return dateA - dateB;
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