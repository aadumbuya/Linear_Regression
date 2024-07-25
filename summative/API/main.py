from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np

# Load the model
with open('model.pkl', 'rb') as f:
    model = joblib.load(f)

# Define the input data model
class PredictionInput(BaseModel):
    Store: int
    Holiday_Flag: int
    Temperature: float
    Fuel_Price: float
    CPI: float
    Unemployment: float

# Create the FastAPI app
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/predict")
def predict(input_data: PredictionInput):
    # Convert input data to numpy array
    data = np.array([[input_data.Store, input_data.Holiday_Flag, input_data.Temperature, input_data.Fuel_Price, input_data.CPI, input_data.Unemployment]])

    # Make the prediction
    prediction = model.predict(data)

    # Return the prediction
    return {"Weekly_Sales": prediction[0]}

# To run the app, use the command:
# uvicorn script_name:app --reload
