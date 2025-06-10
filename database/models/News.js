// News.js
import mongoose from "mongoose";

const newsSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    summary: {
      type: String,
      required: true,
      trim: true,
    },
    content: {
      type: String,
      required: true,
    },
    category: {
      type: String,
      required: true,
      enum: ["health", "lifestyle", "medical", "research", "guide"],
    },
    coverImage: {
      type: String,
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      //required: true,
    },
    viewCount: {
      type: Number,
      default: 0,
    },
    GoogleDocsId: {
      type: String,
      default: ''
    },
    viewHistory: {
      type: [{
        date: Date,
        count: Number
      }],
      default: []
    }
  },
  {
    timestamps: true,
  }
);

const News = mongoose.model("News", newsSchema);

export default News;
