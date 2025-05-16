export class Image {
  constructor(id, url, type, createdAt, updatedAt) {
    this.id = id;
    this.url = url;
    this.type = type; // Ví dụ: 'banner', 'profile', 'product', etc.
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  static fromJson(json) {
    return new Image(
      json.id,
      json.url,
      json.type,
      json.created_at,
      json.updated_at
    );
  }

  toJson() {
    return {
      id: this.id,
      url: this.url,
      type: this.type,
      created_at: this.createdAt,
      updated_at: this.updatedAt
    };
  }
} 