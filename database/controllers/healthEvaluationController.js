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

      // Log dữ liệu đầu vào để debug
      console.log('symptoms:', symptoms);
      console.log('allergies:', allergies);
      console.log('lifestyle:', lifestyle);
      console.log('healthData:', healthData);

      // Prompt mới yêu cầu trả về đúng cấu trúc JSON
      const prompt = `
Bạn là một bác sĩ AI. Hãy đánh giá sức khỏe dựa trên các thông tin sau:

Triệu chứng:
${JSON.stringify(symptoms, null, 2)}

Dị ứng:
${JSON.stringify(allergies, null, 2)}

Lối sống:
${JSON.stringify(lifestyle, null, 2)}

Dữ liệu sức khỏe:
${JSON.stringify(healthData, null, 2)}

Hãy trả lời đúng theo cấu trúc JSON sau (KHÔNG GIẢI THÍCH, KHÔNG THÊM GÌ NGOÀI JSON):

{
  "detailedEvaluation": {
    "Triệu chứng": {
      "Tên triệu chứng": "Đánh giá chi tiết"
    },
    "Dị ứng": {
      "Tên dị ứng": "Đánh giá chi tiết"
    },
    "Lối sống": "Đánh giá lối sống",
    "Dữ liệu sức khỏe": "Đánh giá dữ liệu sức khỏe"
  },
  "conclusion": "Kết luận tổng quan",
  "recommendations": [
    "Lời khuyên 1",
    "Lời khuyên 2"
  ]
}
`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      console.log('response text:', text);

      let evaluation;
      try {
        // Tìm đoạn JSON đầu tiên trong text
        const jsonStart = text.indexOf('{');
        const jsonEnd = text.lastIndexOf('}');
        if (jsonStart !== -1 && jsonEnd !== -1) {
          const jsonString = text.substring(jsonStart, jsonEnd + 1);
          evaluation = JSON.parse(jsonString);
        } else {
          throw new Error('No JSON found');
        }
      } catch (e) {
        evaluation = parseEvaluationResponse(text);
      }

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