SafeEats is a real-time food allergy detection application built using Flutter, designed to help users identify potential allergens in food before consumption. By combining mobile technology with machine learning, SafeEats empowers individuals—especially those with severe allergies—to make safer eating decisions.

The app leverages Roboflow 3.0 Object Detection, powered by a custom-trained YOLOv8 model, to analyze food images in real time. Using the device camera, SafeEats detects allergenic ingredients with high accuracy and displays them to the user along with confidence scores.

Firebase serves as the backend, providing secure user authentication, real-time data storage, and cross-device cloud synchronization. Detected allergens—along with merged confidence scores for repeated classes—are stored in Cloud Firestore. Users can also personalize allergy settings, save scan history, and manage their profiles for a tailored and consistent experience.
