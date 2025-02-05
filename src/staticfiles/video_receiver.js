const remoteVideo = document.getElementById("remoteVideo");
const signalingServer = new WebSocket("ws://localhost:3000"); // Replace with ngrok URL later
const peerConnection = new RTCPeerConnection();

// Show incoming video stream
peerConnection.ontrack = (event) => {
  remoteVideo.srcObject = event.streams[0];
};

// Signaling events
peerConnection.onicecandidate = (event) => {
  if (event.candidate) {
    signalingServer.send(JSON.stringify({ candidate: event.candidate }));
  }
};

signalingServer.onmessage = (message) => {
  const data = JSON.parse(message.data);

  if (data.answer) {
    peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
  } else if (data.candidate) {
    peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
  } else if (data.offer) {
    peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    peerConnection
      .createAnswer()
      .then((answer) => peerConnection.setLocalDescription(answer))
      .then(() =>
        signalingServer.send(
          JSON.stringify({ answer: peerConnection.localDescription })
        )
      );
  }
};

// Create an offer
peerConnection
  .createOffer()
  .then((offer) => peerConnection.setLocalDescription(offer))
  .then(() =>
    signalingServer.send(
      JSON.stringify({ offer: peerConnection.localDescription })
    )
  );
