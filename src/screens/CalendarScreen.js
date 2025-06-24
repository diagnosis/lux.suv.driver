import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  FlatList,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Calendar } from 'react-native-calendars';
import { Ionicons } from '@expo/vector-icons';
import { useRides } from '../context/RideContext';
import RideDetailModal from '../components/RideDetailModal';

export default function CalendarScreen() {
  const { rides, fetchRides, ridesForDate } = useRides();
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedRide, setSelectedRide] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);

  useEffect(() => {
    fetchRides();
  }, []);

  const getMarkedDates = () => {
    const marked = {};
    
    rides.forEach(ride => {
      if (ride.date) {
        marked[ride.date] = {
          marked: true,
          dotColor: '#CDB649',
        };
      }
    });

    // Mark selected date
    marked[selectedDate] = {
      ...marked[selectedDate],
      selected: true,
      selectedColor: '#CDB649',
    };

    return marked;
  };

  const selectedDateRides = ridesForDate(new Date(selectedDate));

  const formatSelectedDate = () => {
    const date = new Date(selectedDate);
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'short',
      day: 'numeric',
    });
  };

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

  const renderCompactRideCard = ({ item: ride }) => (
    <TouchableOpacity
      style={styles.compactRideCard}
      onPress={() => handleRidePress(ride)}
    >
      <View style={styles.compactRideTime}>
        <Text style={styles.timeText}>{ride.time}</Text>
        <View style={[styles.statusDot, { backgroundColor: getStatusColor(ride.status) }]} />
      </View>

      <View style={styles.compactRideInfo}>
        <View style={styles.locationRow}>
          <View style={[styles.locationDot, { backgroundColor: '#10B981' }]} />
          <Text style={styles.compactLocationText} numberOfLines={1}>
            {ride.pickup}
          </Text>
        </View>
        <View style={styles.locationRow}>
          <View style={[styles.locationDot, { backgroundColor: '#EF4444' }]} />
          <Text style={styles.compactLocationText} numberOfLines={1}>
            {ride.dropoff}
          </Text>
        </View>
      </View>

      {ride.fare && (
        <Text style={styles.compactFareText}>${ride.fare.toFixed(2)}</Text>
      )}
    </TouchableOpacity>
  );

  return (
    <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Schedule</Text>
        <TouchableOpacity onPress={fetchRides} style={styles.refreshButton}>
          <Ionicons name="refresh" size={18} color="#FFF" />
        </TouchableOpacity>
      </View>

      <View style={styles.calendarContainer}>
        <Calendar
          current={selectedDate}
          onDayPress={(day) => setSelectedDate(day.dateString)}
          markedDates={getMarkedDates()}
          theme={{
            backgroundColor: 'transparent',
            calendarBackground: 'rgba(255, 255, 255, 0.1)',
            textSectionTitleColor: '#D1D5DB',
            selectedDayBackgroundColor: '#CDB649',
            selectedDayTextColor: '#000',
            todayTextColor: '#CDB649',
            dayTextColor: '#FFF',
            textDisabledColor: '#6B7280',
            dotColor: '#CDB649',
            selectedDotColor: '#000',
            arrowColor: '#CDB649',
            monthTextColor: '#FFF',
            indicatorColor: '#CDB649',
            textDayFontWeight: '500',
            textMonthFontWeight: 'bold',
            textDayHeaderFontWeight: '600',
            textDayFontSize: 16,
            textMonthFontSize: 18,
            textDayHeaderFontSize: 14,
          }}
          style={styles.calendar}
        />
      </View>

      <View style={styles.selectedDateSection}>
        <View style={styles.selectedDateHeader}>
          <Text style={styles.selectedDateTitle}>{formatSelectedDate()}</Text>
          <Text style={styles.rideCount}>
            {selectedDateRides.length} ride{selectedDateRides.length !== 1 ? 's' : ''}
          </Text>
        </View>

        {selectedDateRides.length === 0 ? (
          <View style={styles.noRidesContainer}>
            <Ionicons name="calendar-outline" size={40} color="#6B7280" />
            <Text style={styles.noRidesText}>No rides scheduled</Text>
          </View>
        ) : (
          <FlatList
            data={selectedDateRides.sort((a, b) => a.time.localeCompare(b.time))}
            renderItem={renderCompactRideCard}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.ridesList}
            showsVerticalScrollIndicator={false}
          />
        )}
      </View>

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
  calendarContainer: {
    paddingHorizontal: 24,
    marginBottom: 20,
  },
  calendar: {
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 10,
  },
  selectedDateSection: {
    flex: 1,
    paddingHorizontal: 24,
  },
  selectedDateHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  selectedDateTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#FFF',
  },
  rideCount: {
    fontSize: 14,
    fontWeight: '500',
    color: '#D1D5DB',
  },
  noRidesContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 12,
  },
  noRidesText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#9CA3AF',
  },
  ridesList: {
    paddingBottom: 100,
  },
  compactRideCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 16,
    marginBottom: 12,
    gap: 16,
  },
  compactRideTime: {
    alignItems: 'center',
    width: 80,
    gap: 8,
  },
  timeText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#FFF',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  compactRideInfo: {
    flex: 1,
    gap: 8,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  locationDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 8,
  },
  compactLocationText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#E5E7EB',
    flex: 1,
  },
  compactFareText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#CDB649',
  },
});