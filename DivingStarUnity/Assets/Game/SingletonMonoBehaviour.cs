using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingletonMonoBehaviour<T> : MonoBehaviour where T : MonoBehaviour
{

	/// <summary>
	/// 
	/// </summary>
	public static T Instance
	{
		get {
			if (_instance == null) {
				_instance = CreateSingletonInstance();
			}
			return _instance;
		}
	}

	#region MonoBehaviour Method.
	/// <summary>
	/// MonoBehaviourコンストラクタ
	/// </summary>
	private void Awake()
	{
		if(_instance == null){
			_instance = this as T;
		}
	}
	#endregion MonoBehaviour Method.

	public void Initialize()
	{
	}


	/// <summary>
	/// シングルトンインスタンス生成.
	/// </summary>
	/// <param name="addTarget"></param>
	/// <returns></returns>
	public static T CreateSingletonInstance()
	{
		var addTarget = new GameObject(typeof(T).FullName);
		GameObject.DontDestroyOnLoad(addTarget);

		T mono = addTarget.AddComponent<T>();
		return mono;
	}

	protected static T _instance = null;
}
