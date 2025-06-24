import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useRides } from '../context/RideContext';
import RideDetailModal from '../components/RideDetailModal';

export default function RidesListScreen() {
  const { rides, isLoading, errorMessage, fetchRides } = useRides();
  const [selectedRide, setSelectedRide] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    fetchRides();
  }, []);

  const handleRidePress = (ride) => {
    setSelectedRide(ride);
    setModalVisible(true);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'requested': return '#3B82F6';
      case 'accepted': return '#10B981';
      case 'in_progress': return '#F59E0B';
      case 'completed': return '#6B7280';
      case 'cancelled': return '#EF4444';
      default: return '#6B7280';
    }
  };

  const formatTime = (date, time) => {
    const dateObj = new Date(`${date} ${time}`);
    return dateObj.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    });
  };

  const renderRideCard = ({ item: ride }) => (
    <TouchableOpacity
      style={styles.rideCard}
      onPress={() => handleRidePress(ride)}
    >
      <View style={styles.rideHeader}>
        <View>
          <Text style={styles.customerName}>
            {ride.name || 'Unknown Customer'}
          </Text>
          <Text style={styles.rideTime}>
            {formatTime(ride.date, ride.time)}
          </Text>
        </View>
        
        <View style={styles.rideHeaderRight}>
          <View style={[styles.statusBadge, { backgroundColor: `${getStatusColor(ride.status)}33` }]}>
            <Text style={[styles.statusText, { color: getStatusColor(ride.status) }]}>
              {ride.status?.replace('_', ' ').toUpperCase() || 'REQUESTED'}
            </Text>
          </View>
          {ride.fare && (
            <Text style={styles.fareText}>${ride.fare.toFixed(2)}</Text>
          )}
        </View>
      </View>

      <View style={styles.locationsContainer}>
        <View style={styles.locationRow}>
          <View style={[styles.locationDot, { backgroundColor: '#10B981' }]} />
          <Text style={styles.locationText} numberOfLines={2}>
            {ride.pickup}
          </Text>
        </View>
        <View style={styles.locationRow}>
          <View style={[styles.locationDot, { backgroundColor: '#EF4444' }]} />
          <Text style={styles.locationText} numberOfLines={2}>
            {ride.dropoff}
          </Text>
        </View>
      </View>

      {(ride.distance || ride.duration) && (
        <View style={styles.tripInfo}>
          {ride.distance && (
            <View style={styles.tripInfoItem}>
              <Ionicons name="location-outline" size={12} color="#9CA3AF" />
              <Text style={styles.tripInfoText}>{ride.distance.toFixed(1)} mi</Text>
            </View>
          )}
          {ride.duration && (
            <View style={styles.tripInfoItem}>
              <Ionicons name="time-outline" size={12} color="#9CA3AF" />
              <Text style={styles.tripInfoText}>{ride.duration} min</Text>
            </View>
          )}
        </View>
      )}
    </TouchableOpacity>
  );

  return (
    <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>My Rides</Text>
        <TouchableOpacity
          onPress={fetchRides}
          disabled={isLoading}
          style={styles.refreshButton}
        >
          <Ionicons name="refresh" size={18} color="#FFF" />
        </TouchableOpacity>
      </View>

      {isLoading && rides.length === 0 ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#CDB649" />
        </View>
      ) : rides.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Ionicons name="car-outline" size={60} color="#6B7280" />
          <Text style={styles.emptyTitle}>No rides available</Text>
          <Text style={styles.emptySubtitle}>New ride requests will appear here</Text>
        </View>
      ) : (
        <FlatList
          data={rides}
          renderItem={renderRideCard}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContainer}
          refreshControl={
            <RefreshControl
              refreshing={isLoading}
              onRefresh={fetchRides}
              tintColor="#CDB649"
            />
          }
        />
      )}

      {errorMessage && (
        <View style={styles.errorContainer}>
          <View style={styles.errorMessage}>
            <Ionicons name="warning" size={16} color="#EF4444" />
            <Text style={styles.errorText}>{errorMessage}</Text>
          </View>
        </View>
      )}

      <RideDetailModal
        visible={modalVisible}
        ride={selectedRide}
        onClose={() => setModalVisible(false)}
      />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 16,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFF',
  },
  refreshButton: {
    padding: 10,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 50,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '500',
    color: '#D1D5DB',
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#9CA3AF',
  },
  listContainer: {
    paddingHorizontal: 24,
    paddingBottom: 100,
  },
  rideCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 20,
    marginBottom: 12,
  },
  rideHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  customerName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFF',
    marginBottom: 4,
  },
  rideTime: {
    fontSize: 14,
    fontWeight: '500',
    color: '#D1D5DB',
  },
  rideHeaderRight: {
    alignItems: 'flex-end',
    gap: 4,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '600',
  },
  fareText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#CDB649',
  },
  locationsContainer: {
    gap: 12,
    marginBottom: 12,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  locationDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 12,
  },
  locationText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#E5E7EB',
    flex: 1,
  },
  tripInfo: {
    flexDirection: 'row',
    gap: 24,
  },
  tripInfoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  tripInfoText: {
    fontSize: 12,
    fontWeight: '500',
    color: '#9CA3AF',
  },
  errorContainer: {
    position: 'absolute',
    bottom: 100,
    left: 24,
    right: 24,
  },
  errorMessage: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
    borderColor: 'rgba(239, 68, 68, 0.5)',
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    gap: 8,
  },
  errorText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#FFF',
    flex: 1,
  },
});