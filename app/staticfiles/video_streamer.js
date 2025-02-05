const localVideo = document.getElementById("localVideo");
const signalingServer = new WebSocket("ws://localhost:3000"); // Replace with ngrok URL later
const peerConnection = new RTCPeerConnection();

// Stream camera feed
navigator.mediaDevices
  .getUserMedia({ video: true, audio: false })
  .then((stream) => {
    localVideo.srcObject = stream;
    stream
      .getTracks()
      .forEach((track) => peerConnection.addTrack(track, stream));
  })
  .catch((error) => console.error("Error accessing camera: ", error));

// Signaling events
peerConnection.onicecandidate = (event) => {
  if (event.candidate) {
    signalingServer.send(JSON.stringify({ candidate: event.candidate }));
  }
};

signalingServer.onmessage = (message) => {
  const data = JSON.parse(message.data);

  if (data.offer) {
    peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    peerConnection
      .createAnswer()
      .then((answer) => peerConnection.setLocalDescription(answer))
      .then(() =>
        signalingServer.send(
          JSON.stringify({ answer: peerConnection.localDescription })
        )
      );
  } else if (data.candidate) {
    peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
  }
};
