import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Linking,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { X, Car, Clock, Users, Mail, Phone, MapPin, Edit, Trash2 } from 'lucide-react-native';
import { useRides } from '@/contexts/RideContext';
import RideUpdateModal from './RideUpdateModal';

interface RideDetailModalProps {
  visible: boolean;
  ride: any;
  onClose: () => void;
}

export default function RideDetailModal({ visible, ride, onClose }: RideDetailModalProps) {
  const { updateRide, deleteRide } = useRides();
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);

  if (!ride) return null;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'requested': return '#3B82F6';
      case 'accepted': return '#10B981';
      case 'in_progress': return '#F59E0B';
      case 'completed': return '#6B7280';
      case 'cancelled': return '#EF4444';
      default: return '#6B7280';
    }
  };

  const formatDateTime = () => {
    return `${ride.date} at ${ride.time}`;
  };

  const getRideTypeDisplay = () => {
    if (!ride.rideType) return 'Standard';
    return ride.rideType.replace('_', ' ').replace(/\b\w/g, (l: string) => l.toUpperCase());
  };

  const handleCall = (phoneNumber: string) => {
    Linking.openURL(`tel:${phoneNumber}`);
  };

  const handleEmail = (email: string) => {
    Linking.openURL(`mailto:${email}`);
  };

  const handleUpdateRide = async (newStatus: string, notes?: string) => {
    setIsUpdating(true);
    const success = await updateRide(ride.id, newStatus, notes);
    setIsUpdating(false);
    
    if (success) {
      setShowUpdateModal(false);
      onClose();
    }
  };

  const handleDeleteRide = () => {
    Alert.alert(
      'Cancel Ride',
      'Are you sure you want to cancel this ride? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            setIsUpdating(true);
            const success = await deleteRide(ride.id);
            setIsUpdating(false);
            if (success) {
              onClose();
            }
          },
        },
      ]
    );
  };

  return (
    <>
      <Modal
        visible={visible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={onClose}
      >
        <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.headerTitle}>Ride Details</Text>
            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <X size={24} color="#CDB649" />
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
            {/* Header Card */}
            <View style={styles.card}>
              <View style={styles.cardHeader}>
                <View>
                  <Text style={styles.customerName}>
                    {ride.name || 'Unknown Customer'}
                  </Text>
                  <Text style={styles.rideId}>
                    Ride #{ride.id.substring(0, 8)}
                  </Text>
                </View>
                
                <View style={styles.cardHeaderRight}>
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
            </View>

            {/* Ride Information */}
            <View style={styles.card}>
              <Text style={styles.cardTitle}>Ride Information</Text>
              
              <View style={styles.infoRow}>
                <Car size={20} color="#CDB649" />
                <View style={styles.infoContent}>
                  <Text style={styles.infoLabel}>Ride Type</Text>
                  <Text style={styles.infoValue}>{getRideTypeDisplay()}</Text>
                </View>
              </View>

              <View style={styles.infoRow}>
                <Clock size={20} color="#3B82F6" />
                <View style={styles.infoContent}>
                  <Text style={styles.infoLabel}>Scheduled Time</Text>
                  <Text style={styles.infoValue}>{formatDateTime()}</Text>
                </View>
              </View>

              {ride.numberOfPassengers && (
                <View style={styles.infoRow}>
                  <Users size={20} color="#8B5CF6" />
                  <View style={styles.infoContent}>
                    <Text style={styles.infoLabel}>Passengers</Text>
                    <Text style={styles.infoValue}>
                      {ride.numberOfPassengers} passenger{ride.numberOfPassengers !== 1 ? 's' : ''}
                    </Text>
                  </View>
                  {ride.numberOfLuggage && (
                    <View style={styles.luggageInfo}>
                      <Text style={styles.infoLabel}>Luggage</Text>
                      <Text style={styles.infoValue}>
                        {ride.numberOfLuggage} bag{ride.numberOfLuggage !== 1 ? 's' : ''}
                      </Text>
                    </View>
                  )}
                </View>
              )}
            </View>

            {/* Route */}
            <View style={styles.card}>
              <Text style={styles.cardTitle}>Route</Text>
              
              <View style={styles.routeContainer}>
                <View style={styles.routeRow}>
                  <View style={[styles.routeDot, { backgroundColor: '#10B981' }]} />
                  <View style={styles.routeContent}>
                    <Text style={styles.routeLabel}>Pickup Location</Text>
                    <Text style={styles.routeText}>{ride.pickup}</Text>
                  </View>
                </View>

                <View style={styles.routeRow}>
                  <View style={[styles.routeDot, { backgroundColor: '#EF4444' }]} />
                  <View style={styles.routeContent}>
                    <Text style={styles.routeLabel}>Dropoff Location</Text>
                    <Text style={styles.routeText}>{ride.dropoff}</Text>
                  </View>
                </View>
              </View>
            </View>

            {/* Customer Information */}
            <View style={styles.card}>
              <Text style={styles.cardTitle}>Customer</Text>
              
              <View style={styles.infoRow}>
                <Users size={20} color="#8B5CF6" />
                <View style={styles.infoContent}>
                  <Text style={styles.infoValue}>{ride.name || 'Unknown Customer'}</Text>
                </View>
              </View>

              {ride.email && (
                <View style={styles.infoRow}>
                  <Mail size={20} color="#3B82F6" />
                  <View style={styles.infoContent}>
                    <Text style={styles.infoValue}>{ride.email}</Text>
                  </View>
                  <TouchableOpacity onPress={() => handleEmail(ride.email)}>
                    <Mail size={24} color="#3B82F6" />
                  </TouchableOpacity>
                </View>
              )}

              {ride.phoneNumber && (
                <View style={styles.infoRow}>
                  <Phone size={20} color="#10B981" />
                  <View style={styles.infoContent}>
                    <Text style={styles.infoValue}>{ride.phoneNumber}</Text>
                  </View>
                  <TouchableOpacity onPress={() => handleCall(ride.phoneNumber)}>
                    <Phone size={24} color="#10B981" />
                  </TouchableOpacity>
                </View>
              )}
            </View>

            {/* Trip Details */}
            {(ride.distance || ride.duration) && (
              <View style={styles.card}>
                <Text style={styles.cardTitle}>Trip Details</Text>
                <View style={styles.tripDetailsRow}>
                  {ride.distance && (
                    <View style={styles.tripDetail}>
                      <Text style={styles.tripDetailValue}>{ride.distance.toFixed(1)}</Text>
                      <Text style={styles.tripDetailLabel}>miles</Text>
                    </View>
                  )}
                  {ride.duration && (
                    <View style={styles.tripDetail}>
                      <Text style={styles.tripDetailValue}>{ride.duration}</Text>
                      <Text style={styles.tripDetailLabel}>minutes</Text>
                    </View>
                  )}
                </View>
              </View>
            )}

            {/* Notes */}
            {ride.additionalNotes && (
              <View style={styles.card}>
                <Text style={styles.cardTitle}>Additional Notes</Text>
                <Text style={styles.notesText}>{ride.additionalNotes}</Text>
              </View>
            )}

            {/* Action Buttons */}
            {(ride.status === 'requested' || ride.status === 'accepted') && (
              <View style={styles.actionsContainer}>
                <TouchableOpacity
                  style={styles.updateButton}
                  onPress={() => setShowUpdateModal(true)}
                  disabled={isUpdating}
                >
                  <LinearGradient
                    colors={['#CDB649', '#E6CC52']}
                    style={styles.updateButtonGradient}
                  >
                    <Edit size={18} color="#000" />
                    <Text style={styles.updateButtonText}>Update Status</Text>
                  </LinearGradient>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.deleteButton}
                  onPress={handleDeleteRide}
                  disabled={isUpdating}
                >
                  <Trash2 size={18} color="#FFF" />
                  <Text style={styles.deleteButtonText}>Cancel Ride</Text>
                </TouchableOpacity>
              </View>
            )}
          </ScrollView>
        </LinearGradient>
      </Modal>

      <RideUpdateModal
        visible={showUpdateModal}
        ride={ride}
        onClose={() => setShowUpdateModal(false)}
        onUpdate={handleUpdateRide}
      />
    </>
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
    paddingBottom: 20,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  closeButton: {
    padding: 8,
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },
  card: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 24,
    marginBottom: 16,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  customerName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
    marginBottom: 4,
    fontFamily: 'Inter-Bold',
  },
  rideId: {
    fontSize: 14,
    fontWeight: '500',
    color: '#D1D5DB',
    fontFamily: 'Inter-Medium',
  },
  cardHeaderRight: {
    alignItems: 'flex-end',
    gap: 8,
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  statusText: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: 'Inter-SemiBold',
  },
  fareText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#CDB649',
    fontFamily: 'Inter-Bold',
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFF',
    marginBottom: 16,
    fontFamily: 'Inter-SemiBold',
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    gap: 12,
  },
  infoContent: {
    flex: 1,
    gap: 2,
  },
  infoLabel: {
    fontSize: 12,
    fontWeight: '500',
    color: '#D1D5DB',
    fontFamily: 'Inter-Medium',
  },
  infoValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFF',
    fontFamily: 'Inter-SemiBold',
  },
  luggageInfo: {
    alignItems: 'flex-end',
    gap: 2,
  },
  routeContainer: {
    gap: 16,
  },
  routeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  routeDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  routeContent: {
    flex: 1,
    gap: 2,
  },
  routeLabel: {
    fontSize: 12,
    fontWeight: '500',
    color: '#D1D5DB',
    fontFamily: 'Inter-Medium',
  },
  routeText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#FFF',
    fontFamily: 'Inter-Medium',
  },
  tripDetailsRow: {
    flexDirection: 'row',
    gap: 24,
  },
  tripDetail: {
    alignItems: 'center',
    gap: 4,
  },
  tripDetailValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  tripDetailLabel: {
    fontSize: 12,
    fontWeight: '500',
    color: '#D1D5DB',
    fontFamily: 'Inter-Medium',
  },
  notesText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#E5E7EB',
    lineHeight: 24,
    fontFamily: 'Inter-Medium',
  },
  actionsContainer: {
    gap: 12,
    marginBottom: 40,
  },
  updateButton: {
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  updateButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    borderRadius: 12,
    gap: 8,
  },
  updateButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    fontFamily: 'Inter-SemiBold',
  },
  deleteButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
    borderColor: 'rgba(239, 68, 68, 0.5)',
    borderWidth: 1,
    borderRadius: 12,
    paddingVertical: 16,
    gap: 8,
  },
  deleteButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFF',
    fontFamily: 'Inter-SemiBold',
  },
});