import VideoCall from '../models/VideoCall.js';
import Consultation from '../models/Consultation.js';

export const startVideoCall = async (req, res) => {
  try {
    const { consultationId, offer, isDoctor } = req.body;
    const userId = req.user.userId;

    // Tìm cuộc tư vấn
    const consultation = await Consultation.findById(consultationId);
    if (!consultation) {
      return res.status(404).json({ message: 'Không tìm thấy cuộc tư vấn' });
    }

    // Tạo hoặc cập nhật video call
    let videoCall = await VideoCall.findOne({ consultationId });
    if (!videoCall) {
      videoCall = new VideoCall({
        consultationId,
        userId: consultation.userId,
        doctorId: consultation.doctorId,
        offer: isDoctor ? null : offer,
        answer: isDoctor ? offer : null
      });
    } else {
      if (isDoctor) {
        videoCall.answer = offer;
      } else {
        videoCall.offer = offer;
      }
    }

    videoCall.status = 'active';
    await videoCall.save();

    // Trả về offer hoặc answer tương ứng
    res.json({
      success: true,
      data: isDoctor ? videoCall.offer : videoCall.answer
    });

  } catch (error) {
    console.error('Lỗi khởi tạo cuộc gọi video:', error);
    res.status(500).json({ message: 'Lỗi khởi tạo cuộc gọi video' });
  }
};

export const endVideoCall = async (req, res) => {
  try {
    const { consultationId } = req.body;

    const videoCall = await VideoCall.findOne({ consultationId });
    if (videoCall) {
      videoCall.status = 'ended';
      videoCall.endTime = new Date();
      await videoCall.save();
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Lỗi kết thúc cuộc gọi video:', error);
    res.status(500).json({ message: 'Lỗi kết thúc cuộc gọi video' });
  }
}; 