import axios from 'axios';
import MedicalRecord from '../models/MedicalRecord';
import axiosInstance from './axiosInstance';

export default {
    async getMedicalRecords(userId) {
        try {
            const response = await axiosInstance.get(`/medical-records/${userId}`);
            return response.data.map(record => new MedicalRecord(record));
        } catch (error) {
            console.error('Error fetching medical records:', error);
            throw error;
        }
    },

    async getMedicalRecordById(id) {
        try {
            const response = await axiosInstance.get(`/medical-records/detail/${id}`);
            return new MedicalRecord(response.data);
        } catch (error) {
            console.error('Error fetching medical record:', error);
            throw error;
        }
    },

    async createMedicalRecord(recordData) {
        try {
            const response = await axiosInstance.post(`/medical-records`, recordData);
            return new MedicalRecord(response.data);
        } catch (error) {
            console.error('Error creating medical record:', error);
            throw error;
        }
    },

    async updateMedicalRecord(id, recordData) {
        try {
            const response = await axiosInstance.put(`/medical-records/${id}`, recordData);
            return new MedicalRecord(response.data);
        } catch (error) {
            console.error('Error updating medical record:', error);
            throw error;
        }
    },

    async deleteMedicalRecord(id) {
        try {
            await axiosInstance.delete(`/medical-records/${id}`);
            return true;
        } catch (error) {
            console.error('Error deleting medical record:', error);
            throw error;
        }
    },

    async uploadAttachment(recordId, file) {
        try {
            const formData = new FormData();
            formData.append('file', file);
            const response = await axiosInstance.post(`/medical-records/${recordId}/attachments`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            return response.data;
        } catch (error) {
            console.error('Error uploading attachment:', error);
            throw error;
        }
    }
}; 