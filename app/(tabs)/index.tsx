import React, { useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { LogOut, MapPin, Clock, BarChart, User } from 'lucide-react-native';
import { useAuth } from '@/contexts/AuthContext';
import { useRides } from '@/contexts/RideContext';

export default function DashboardScreen() {
  const { currentDriver, logout } = useAuth();
  const { rides, isLoading, fetchRides, upcomingRides } = useRides();

  useEffect(() => {
    fetchRides();
  }, []);

  const todaysRideCount = () => {
    const today = new Date().toISOString().split('T')[0];
    return rides.filter(ride => ride.date === today).length;
  };

  return (
    <LinearGradient colors={['#0D0D1A', '#1A1A33']} style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={isLoading} onRefresh={fetchRides} />
        }
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerContent}>
            <View>
              <Text style={styles.welcomeText}>Welcome back,</Text>
              <Text style={styles.nameText}>
                {currentDriver?.name || currentDriver?.username || 'Driver'}
              </Text>
            </View>
            
            <TouchableOpacity onPress={logout} style={styles.logoutButton}>
              <LogOut size={20} color="#FFF" />
            </TouchableOpacity>
          </View>

          {/* Status Card */}
          <View style={styles.statusCard}>
            <View>
              <Text style={styles.statusLabel}>Status</Text>
              <View style={styles.statusRow}>
                <View style={styles.statusDot} />
                <Text style={styles.statusText}>Available</Text>
              </View>
            </View>
            
            <View style={styles.todayRides}>
              <Text style={styles.todayLabel}>Today's Rides</Text>
              <Text style={styles.todayCount}>{todaysRideCount()}</Text>
            </View>
          </View>
        </View>

        {/* Upcoming Rides */}
        {upcomingRides().length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Upcoming Rides</Text>
              <View style={styles.badge}>
                <Text style={styles.badgeText}>{upcomingRides().length}</Text>
              </View>
            </View>
            
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              <View style={styles.upcomingRidesContainer}>
                {upcomingRides().slice(0, 5).map((ride) => (
                  <UpcomingRideCard key={ride.id} ride={ride} />
                ))}
              </View>
            </ScrollView>
          </View>
        )}

        {/* Quick Actions */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Quick Actions</Text>
          <View style={styles.quickActionsGrid}>
            <QuickActionCard
              icon={<MapPin size={28} color="#10B981" />}
              title="Go Online"
              subtitle="Start accepting rides"
            />
            <QuickActionCard
              icon={<Clock size={28} color="#3B82F6" />}
              title="Schedule"
              subtitle="View your schedule"
            />
            <QuickActionCard
              icon={<BarChart size={28} color="#CDB649" />}
              title="Earnings"
              subtitle="Check your earnings"
            />
            <QuickActionCard
              icon={<User size={28} color="#8B5CF6" />}
              title="Profile"
              subtitle="Update your info"
            />
          </View>
        </View>
      </ScrollView>
    </LinearGradient>
  );
}

const UpcomingRideCard = ({ ride }: { ride: any }) => (
  <View style={styles.upcomingRideCard}>
    <View style={styles.upcomingRideHeader}>
      <Text style={styles.upcomingRideTime}>{ride.time}</Text>
      {ride.fare && (
        <Text style={styles.upcomingRideFare}>${ride.fare}</Text>
      )}
    </View>
    
    <View style={styles.upcomingRideLocations}>
      <View style={styles.locationRow}>
        <View style={[styles.locationDot, { backgroundColor: '#10B981' }]} />
        <Text style={styles.locationText} numberOfLines={1}>
          {ride.pickup}
        </Text>
      </View>
      <View style={styles.locationRow}>
        <View style={[styles.locationDot, { backgroundColor: '#EF4444' }]} />
        <Text style={styles.locationText} numberOfLines={1}>
          {ride.dropoff}
        </Text>
      </View>
    </View>
  </View>
);

const QuickActionCard = ({ icon, title, subtitle }: { icon: React.ReactNode; title: string; subtitle: string }) => (
  <TouchableOpacity style={styles.quickActionCard}>
    {icon}
    <Text style={styles.quickActionTitle}>{title}</Text>
    <Text style={styles.quickActionSubtitle}>{subtitle}</Text>
  </TouchableOpacity>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 20,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  welcomeText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#D1D5DB',
    marginBottom: 4,
    fontFamily: 'Inter-Medium',
  },
  nameText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  logoutButton: {
    padding: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 50,
  },
  statusCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 20,
  },
  statusLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#D1D5DB',
    marginBottom: 8,
    fontFamily: 'Inter-Medium',
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#10B981',
    marginRight: 8,
  },
  statusText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFF',
    fontFamily: 'Inter-SemiBold',
  },
  todayRides: {
    alignItems: 'flex-end',
  },
  todayLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#D1D5DB',
    marginBottom: 8,
    fontFamily: 'Inter-Medium',
  },
  todayCount: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  section: {
    paddingHorizontal: 24,
    marginBottom: 24,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  badge: {
    backgroundColor: 'rgba(205, 182, 73, 0.2)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  badgeText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#CDB649',
    fontFamily: 'Inter-SemiBold',
  },
  upcomingRidesContainer: {
    flexDirection: 'row',
    gap: 16,
  },
  upcomingRideCard: {
    width: 200,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 16,
  },
  upcomingRideHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  upcomingRideTime: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#FFF',
    fontFamily: 'Inter-Bold',
  },
  upcomingRideFare: {
    fontSize: 14,
    fontWeight: '600',
    color: '#CDB649',
    fontFamily: 'Inter-SemiBold',
  },
  upcomingRideLocations: {
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
  locationText: {
    fontSize: 12,
    fontWeight: '500',
    color: '#D1D5DB',
    flex: 1,
    fontFamily: 'Inter-Medium',
  },
  quickActionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 16,
  },
  quickActionCard: {
    flex: 1,
    minWidth: '45%',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    padding: 20,
    alignItems: 'center',
    gap: 12,
  },
  quickActionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFF',
    textAlign: 'center',
    fontFamily: 'Inter-SemiBold',
  },
  quickActionSubtitle: {
    fontSize: 12,
    fontWeight: '500',
    color: '#D1D5DB',
    textAlign: 'center',
    fontFamily: 'Inter-Medium',
  },
});