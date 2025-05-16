export default class MedicalRecord {
    constructor(data = {}) {
        this.id = data.id || null;
        this.patientId = data.patientId || null;
        this.doctorId = data.doctorId || null;
        this.diagnosis = data.diagnosis || '';
        this.symptoms = data.symptoms || '';
        this.treatment = data.treatment || '';
        this.prescription = data.prescription || [];
        this.notes = data.notes || '';
        this.visitDate = data.visitDate || new Date();
        this.nextVisitDate = data.nextVisitDate || null;
        this.status = data.status || 'active'; // active, archived
        this.attachments = data.attachments || [];
        this.createdAt = data.createdAt || new Date();
        this.updatedAt = data.updatedAt || new Date();
    }
} 