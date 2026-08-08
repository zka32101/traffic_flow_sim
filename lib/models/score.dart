class SimulationData {
  final int congestionTimeMs;
  final double avgSpeed;
  final int completedVehicles;

  const SimulationData({
    required this.congestionTimeMs,
    required this.avgSpeed,
    required this.completedVehicles,
  });

  factory SimulationData.fromMap(Map<String, dynamic> map) {
    return SimulationData(
      congestionTimeMs: map['congestionTime'] as int,
      avgSpeed: (map['avgSpeed'] as num).toDouble(),
      completedVehicles: map['completedVehicles'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'congestionTime': congestionTimeMs,
      'avgSpeed': double.parse(avgSpeed.toStringAsFixed(2)),
      'completedVehicles': completedVehicles,
    };
  }
}

class ScoreRecord {
  final String scoreId;
  final String courseId;
  final int score;
  final DateTime timestamp;
  final SimulationData simulationData;

  const ScoreRecord({
    required this.scoreId,
    required this.courseId,
    required this.score,
    required this.timestamp,
    required this.simulationData,
  });

  factory ScoreRecord.fromMap(String id, Map<String, dynamic> map) {
    return ScoreRecord(
      scoreId: id,
      courseId: map['courseId'] as String,
      score: map['score'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestampMs'] as int),
      simulationData:
          SimulationData.fromMap(map['simulationData'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'score': score,
      'timestampMs': timestamp.millisecondsSinceEpoch,
      'simulationData': simulationData.toMap(),
    };
  }
}
