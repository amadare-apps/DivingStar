using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace HyperCasualGames
{

	/// <summary>
	/// controll vibration
	/// </summary>
	public class VibrationController
	{
		public static bool VibrationOff { get; set; }

		// Pu (Single, Weakest)
		public static void Single0()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Single0()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Selection();
#endif
		}

		// Pu (Single, Second Weakest)
		public static void Single1()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Single1()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Impact(TapticPlugin.ImpactFeedback.Light);
#endif
		}

		// Pu (Single, Second strongest)
		public static void Single2()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Single2()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Impact(TapticPlugin.ImpactFeedback.Medium);
#endif
		}

		// Pu (Single, strongest)
		public static void Single3()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Single3()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Impact(TapticPlugin.ImpactFeedback.Heavy);
#endif
		}

		// PuPu (Double, Weak)
		public static void Double0()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Double0()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Notification(TapticPlugin.NotificationFeedback.Success);
#endif
		}

		// PuPu (Double, Strong)
		public static void Double1()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Double1()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Notification(TapticPlugin.NotificationFeedback.Warning);
#endif
		}

		// PuPuPu (Triple, Strong)
		public static void Triple()
		{
			if (VibrationOff) return;
#if UNITY_EDITOR
			Debug.Log("VibrationController.Triple()");
#elif UNITY_IPHONE
			TapticPlugin.TapticManager.Notification(TapticPlugin.NotificationFeedback.Error);
#endif
		}
	}
}