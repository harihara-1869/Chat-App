import axios from "axios";

export const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
});

// Intercept 403 responses that require privacy policy acceptance
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (
      error.response?.status === 403 &&
      error.response?.data?.requiresPrivacyPolicy &&
      !window.location.pathname.includes("/accept-privacy-policy")
    ) {
      window.location.href = "/accept-privacy-policy";
    }
    return Promise.reject(error);
  }
);
