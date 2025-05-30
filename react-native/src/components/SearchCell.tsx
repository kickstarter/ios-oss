import React, { useEffect } from 'react';
import { StyleSheet, Text, View, Image, Dimensions } from 'react-native';
import { ProjectCardFragmentFragment } from '../src/generated/graphql';
import { VideoView, useVideoPlayer } from 'expo-video';
import { LinearGradient } from 'expo-linear-gradient';

const CARD_HEIGHT = 320;
const CARD_RADIUS = 18;
const { width: SCREEN_WIDTH } = Dimensions.get('window');

interface SearchCellProps {
  project: ProjectCardFragmentFragment;
  isVisible?: boolean;
}

export function SearchCell({ project, isVisible }: SearchCellProps): React.JSX.Element {
  const videoUrl = project.lastUploadedVideo?.videoSources?.hls?.src ?? null;
  const imageUrl = project.image?.url ?? null;
  const player = useVideoPlayer(videoUrl || null);
  player.muted = true;

  useEffect(() => {
    if (!player || !videoUrl) return;
    if (isVisible) {
      player.play();
    } else {
      player.pause();
    }
  }, [isVisible, player, videoUrl]);

  return (
    <View style={styles.cardShadow}>
      <View style={styles.card}>
        {videoUrl ? (
          <VideoView
            player={player}
            style={styles.backgroundMedia}
            contentFit="cover"
          />
        ) : imageUrl ? (
          <Image source={{ uri: imageUrl }} style={styles.backgroundMedia} resizeMode="cover" />
        ) : (
          <View style={[styles.backgroundMedia, { backgroundColor: '#222' }]} />
        )}
        <View style={styles.overlay} />
        <LinearGradient
          colors={["rgba(0,0,0,0.55)", "rgba(0,0,0,0)"]}
          start={{ x: 0.5, y: 1 }}
          end={{ x: 0.5, y: 0 }}
          style={styles.gradientOverlay}
        />
        <View style={styles.contentRow}>
          <View style={styles.textColumn}>
            <View style={styles.categoryRow}>
              <View style={styles.categoryPill}>
                <Text style={styles.categoryText}>{project.category?.name ?? 'Uncategorized'}</Text>
              </View>
              <View style={styles.bookmarkIcon} />
            </View>
            <Text style={styles.title} numberOfLines={1}>{project.name}</Text>
            <Text style={styles.subtitle} numberOfLines={1}>{project.description}</Text>
            <View style={styles.metaRow}>
              <Text style={styles.metaText}>{project.creator?.name ?? 'Unknown Creator'}</Text>
              <Text style={styles.metaDot}>•</Text>
              <Text style={styles.metaText}>{getDaysLeft(project.deadlineAt)} days left</Text>
              <Text style={styles.metaDot}>•</Text>
              <Text style={styles.metaText}>{formatCurrency(project.pledged.amount, project.pledged.currency)} raised</Text>
            </View>
          </View>
          <View style={styles.progressColumn}>
            <View style={styles.progressCircle}>
              <Text style={styles.progressText}>{getPercentFunded(project)}</Text>
              <Text style={styles.progressPercent}>%</Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
}

function getDaysLeft(deadlineAt?: any): string {
  if (!deadlineAt) return '?';
  const deadline = new Date(deadlineAt);
  const now = new Date();
  const diff = Math.max(0, Math.ceil((deadline.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)));
  return diff.toString();
}

function getPercentFunded(project: ProjectCardFragmentFragment): string {
  const pledged = parseFloat(project.pledged.amount ?? '0');
  const goal = parseFloat(project.goal?.amount ?? '0');
  if (!goal || isNaN(pledged) || isNaN(goal)) return '0';
  return Math.min(100, Math.round((pledged / goal) * 100)).toString();
}

function formatCurrency(amount?: string | null, currency?: string | null): string {
  if (!amount || !currency) return '';
  if (currency === 'USD') {
    return `$${Number(amount).toLocaleString()}`;
  } else {
    return `${Number(amount).toLocaleString()} ${currency}`;
  }
}

const styles = StyleSheet.create({
  cardShadow: {
    marginHorizontal: 12,
    marginVertical: 10,
    borderRadius: CARD_RADIUS,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.18,
    shadowRadius: 8,
    elevation: 4,
  },
  card: {
    borderRadius: CARD_RADIUS,
    overflow: 'hidden',
    height: CARD_HEIGHT,
    width: SCREEN_WIDTH - 24,
    backgroundColor: '#111',
  },
  backgroundMedia: {
    ...StyleSheet.absoluteFillObject,
    width: '100%',
    height: '100%',
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.38)',
  },
  gradientOverlay: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: CARD_HEIGHT / 3,
    borderBottomLeftRadius: CARD_RADIUS,
    borderBottomRightRadius: CARD_RADIUS,
    zIndex: 2,
  },
  contentRow: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    padding: 18,
  },
  textColumn: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-end',
    minWidth: 0,
    marginRight: 12,
  },
  progressColumn: {
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    minWidth: 56,
  },
  categoryRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
    justifyContent: 'space-between',
  },
  categoryPill: {
    backgroundColor: 'rgba(0,0,0,0.55)',
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 3,
    alignSelf: 'flex-start',
  },
  categoryText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
  bookmarkIcon: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.12)',
    alignSelf: 'flex-end',
  },
  title: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 2,
  },
  subtitle: {
    color: '#fff',
    fontSize: 15,
    marginBottom: 10,
    opacity: 0.92,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  metaText: {
    color: '#fff',
    fontSize: 13,
    opacity: 0.88,
  },
  metaDot: {
    color: '#fff',
    fontSize: 13,
    marginHorizontal: 5,
    opacity: 0.7,
  },
  progressCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(0,0,0,0.72)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  progressText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 18,
    lineHeight: 22,
  },
  progressPercent: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
    lineHeight: 16,
    marginTop: -2,
  },
});
