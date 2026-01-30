import {create } from "zustand";
import { axiosInstance } from "../lib/axios";
import toast from "react-hot-toast";

export const useAuthStore = create((set) => ({
  authUser: null,
  isCheckingAuth: true,
  isSigningUp: false,
  isLoggingIn: false,
  isUpdatingProfile: false,

  checkAuth: async () => {
    try{
      const response = await axiosInstance.get("/auth/get-user");
      set({authUser: response.data})
    }catch(err){
      console.error("Auth check failed:", err);
      set({authUser: null});
    }finally{
      set({isCheckingAuth: false});
    }
  },

  signup: async (data) => {
    set({isSigningUp: true});
    try {
      const res = await axiosInstance.post("/auth/signup", data);
      toast.success("Signup successful!");
      set({authUser: res.data});
    } catch (error) {
      toast.error(error.response?.data?.message || "Signup failed");
    } finally {
      set({isSigningUp: false});
    }
  },

  logout: async () => {
    try{
      await axiosInstance.post("/auth/logout");
      toast.success("Logged out successfully");
    }catch(err){
      console.error("Logout failed:", err);
    }finally{
      set({authUser: null});
    }
  }
}));