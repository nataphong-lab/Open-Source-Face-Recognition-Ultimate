<div align="center">
  <img alt="Open Source Face Recognition" src="" width="400"/>
  
  # Open Source Face Recognition SDK
  
  **The world's first completely free and top #1 open-source face recognition SDK for Windows and Linux and I trained [FacePlugin]'s(https://github.com/Faceplugin-ltd/Open-Source-Face-Recognition-SDK) model to improve the accuracy**

  **The Result is Amazing!!!**
  
</div>

---

## 🚀 Overview

The **Open Source Face Recognition SDK** is the most powerful, privacy-focused solution for integrating face recognition capabilities into your applications. Built with deep learning models, this SDK provides high-accuracy face detection and recognition while ensuring complete data privacy through on-premise processing.

### ✨ Key Features

- 🔒 **100% On-Premise**: All processing happens locally - no data leaves your device
- 🎯 **High Accuracy**: Powered by state-of-the-art deep learning models
- ⚡ **Real-Time Processing**: Fast face detection and recognition capabilities
- 🔧 **Easy Integration**: Simple Python APIs for seamless development
- 🌐 **Cross-Platform**: Compatible with Windows and Linux systems
- 📱 **GPU Optional**: Works efficiently on CPU-only systems
- 🆓 **Completely Free**: Open source with no licensing fees

### 🎯 Current Capabilities

- Face detection and bounding box extraction
- Facial landmark detection
- Feature embedding generation
- Face similarity comparison
- Support for multiple image formats (JPG, PNG, etc.)

---

## 🛠️ Installation

### Prerequisites

- **Python 3.9 or higher**
- **Anaconda** (recommended for dependency management)
- **Windows or Linux** operating system

### Setup Instructions
1. **Setup Test environment** 
powershell -Ep Bypass ./install.ps1

2. **Create and activate conda environment**
   ```bash

   conda create -n facesdk python=3.9
   conda activate facesdk
   ```

3. **Install Anaconda** (if not already installed)
   ```bash
   # Download from: https://www.anaconda.com/products/distribution
   ```

4. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Test the installation**
   ```bash
   python run.py
   ```

---

## 📖 Quick Start

### Basic Usage

```python
from face_recognition_sdk import FaceRecognition

# Initialize the SDK
face_sdk = FaceRecognition()

# Process an image
image_path = "path/to/your/image.jpg"
face_info = face_sdk.GetImageInfo(image_path, faceMaxCount=10)

# Compare two faces
similarity = face_sdk.get_similarity(feature1, feature2)
```

### Example: Face Comparison

```python
# Compare two images
image1 = "test/1.jpg"
image2 = "test/2.png"

# Get face information from both images
faces1 = face_sdk.GetImageInfo(image1, faceMaxCount=1)
faces2 = face_sdk.GetImageInfo(image2, faceMaxCount=1)

if faces1 and faces2:
    # Compare the first face from each image
    similarity = face_sdk.get_similarity(faces1[0]['embedding'], faces2[0]['embedding'])
    print(f"Similarity: {similarity}%")
    
    # Check if it's the same person (threshold = 75)
    is_same_person = similarity >= 75
    print(f"Same person: {is_same_person}")
```

---

## 🔧 API Reference

### Core Functions

#### `GetImageInfo(image_path, faceMaxCount)`
Extracts face information from an image.

**Parameters:**
- `image_path` (str): Path to the input image
- `faceMaxCount` (int): Maximum number of faces to detect

**Returns:**
- List of dictionaries containing:
  - `bbox`: Face bounding box coordinates
  - `landmarks`: Facial landmark points
  - `embedding`: Feature embedding vector

#### `get_similarity(feature1, feature2)`
Compares two face feature embeddings.

**Parameters:**
- `feature1` (array): First face embedding
- `feature2` (array): Second face embedding

**Returns:**
- Similarity score (0-100), where higher values indicate greater similarity

### Configuration

- **Default Threshold**: 75 (for determining if two faces belong to the same person)
- **Supported Formats**: JPG, PNG, BMP, TIFF
- **Face Detection**: Automatic detection of multiple faces per image

---

## 🎯 Use Cases

This SDK is ideal for various applications:

### 🔐 Security & Authentication
- **Access Control Systems**: Secure entry points with face recognition
- **User Authentication**: Biometric login for applications
- **Surveillance**: Real-time monitoring and alerting

### 👥 Business Applications
- **Time & Attendance**: Automated employee check-in/check-out
- **Customer Analytics**: Retail customer tracking and analytics
- **Smart Offices**: Automated visitor management

### 📱 Mobile & IoT
- **Smart Devices**: Integration with IoT devices
- **Mobile Apps**: Face recognition in mobile applications
- **Augmented Reality**: AR applications with facial recognition

---
### 📞 Get in Touch
- **Email**: [nataphong-lab](mailto:nataphong-lab@gmail.com)

---
