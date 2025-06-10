import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ 
  model: "gemini-2.0-flash",
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.7,
  }
});

const healthEvaluationController = {
  evaluateHealth: async (req, res) => {
    try {
      const { symptoms, allergies, lifestyle, healthData } = req.body;

      // Tạo prompt cho Gemini
      const prompt = `
        Hãy đánh giá tình trạng sức khỏe dựa trên các thông tin sau:

        Triệu chứng:
        ${JSON.stringify(symptoms, null, 2)}

        Dị ứng:
        ${JSON.stringify(allergies, null, 2)}

        Lối sống:
        ${JSON.stringify(lifestyle, null, 2)}

        Dữ liệu sức khỏe:
        ${JSON.stringify(healthData, null, 2)}

        Hãy phân tích và đưa ra:
        1. Đánh giá chi tiết từng mục
        2. Kết luận tổng quan về tình trạng sức khỏe
        3. Các lời khuyên và khuyến nghị
      `;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      console.log('response:', response);
      // Phân tích response và format lại thành cấu trúc JSON
      const evaluation = parseEvaluationResponse(text);

      res.json(evaluation);
    } catch (error) {
      console.error('Error in health evaluation:', error);
      res.status(500).json({ 
        error: 'Failed to evaluate health data',
        details: error.message
      });
    }
  }
};

// Hàm helper để parse response từ Gemini thành cấu trúc JSON
function parseEvaluationResponse(text) {
  try {
    // Tách các phần của response
    const sections = text.split('\n\n');
    
    const evaluation = {
      detailedEvaluation: {},
      conclusion: '',
      recommendations: []
    };

    let currentSection = '';
    
    sections.forEach(section => {
      if (section.includes('Đánh giá chi tiết')) {
        currentSection = 'detailedEvaluation';
      } else if (section.includes('Kết luận')) {
        currentSection = 'conclusion';
      } else if (section.includes('Lời khuyên')) {
        currentSection = 'recommendations';
      } else {
        if (currentSection === 'detailedEvaluation') {
          // Parse các đánh giá chi tiết
          const lines = section.split('\n');
          lines.forEach(line => {
            if (line.includes(':')) {
              const [key, value] = line.split(':').map(s => s.trim());
              evaluation.detailedEvaluation[key] = value;
            }
          });
        } else if (currentSection === 'conclusion') {
          evaluation.conclusion = section.trim();
        } else if (currentSection === 'recommendations') {
          // Parse các lời khuyên
          const recommendations = section.split('\n')
            .filter(line => line.trim().startsWith('-') || line.trim().startsWith('•'))
            .map(line => line.replace(/^[-•]\s*/, '').trim());
          evaluation.recommendations = recommendations;
        }
      }
    });

    return evaluation;
  } catch (error) {
    console.error('Error parsing evaluation response:', error);
    return {
      detailedEvaluation: {},
      conclusion: text,
      recommendations: []
    };
  }
}

export default healthEvaluationController; 