import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoCallScreen extends StatefulWidget {
  final String consultationId;
  final bool isDoctor;
  const VideoCallScreen({super.key, required this.consultationId, required this.isDoctor});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late IO.Socket socket;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool cameraEnabled = true;
  bool micEnabled = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSocket();
    _startCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'consultationId': widget.consultationId, 'isDoctor': widget.isDoctor}
    });
    socket.connect();

    socket.on('connect', (_) => print('Socket connected'));
    socket.on('video_call_offer', _onOffer);
    socket.on('video_call_answer', _onAnswer);
    socket.on('video_call_ice_candidate', _onIceCandidate);
    socket.on('video_call_end', (_) => _endCall());
  }

  Future<void> _startCall() async {
    _localStream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    _localRenderer.srcObject = _localStream;

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    _peerConnection?.onIceCandidate = (candidate) {
      socket.emit('video_call_ice_candidate', {
        'consultationId': widget.consultationId,
        'candidate': candidate.toMap(),
        'isDoctor': widget.isDoctor
      });
    };

    if (widget.isDoctor) {
      // Đợi offer từ user
    } else {
      // User tạo offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      socket.emit('video_call_offer', {
        'consultationId': widget.consultationId,
        'offer': offer.toMap(),
        'isDoctor': false
      });
    }
  }

  void _onOffer(data) async {
    if (!widget.isDoctor) return;
    RTCSessionDescription offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    await _peerConnection!.setRemoteDescription(offer);
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socket.emit('video_call_answer', {
      'consultationId': widget.consultationId,
      'answer': answer.toMap(),
      'isDoctor': true
    });
  }

  void _onAnswer(data) async {
    if (widget.isDoctor) return;
    RTCSessionDescription answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
    await _peerConnection!.setRemoteDescription(answer);
  }

  void _onIceCandidate(data) async {
    var candidate = RTCIceCandidate(
      data['candidate']['candidate'],
      data['candidate']['sdpMid'],
      data['candidate']['sdpMLineIndex'],
    );
    await _peerConnection?.addCandidate(candidate);
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(cameraEnabled ? Icons.videocam : Icons.videocam_off),
                onPressed: () {
                  setState(() {
                    cameraEnabled = !cameraEnabled;
                    _localStream?.getVideoTracks()[0].enabled = cameraEnabled;
                  });
                },
              ),
              IconButton(
                icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                onPressed: () {
                  setState(() {
                    micEnabled = !micEnabled;
                    _localStream?.getAudioTracks()[0].enabled = micEnabled;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _endCall,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 