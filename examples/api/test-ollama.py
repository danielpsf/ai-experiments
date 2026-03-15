# Test Ollama API connection
import requests
import json


def test_ollama_connection():
    """Test basic Ollama API connectivity"""
    try:
        # Test version endpoint
        response = requests.get("http://localhost:11434/api/version")
        if response.status_code == 200:
            print("✅ Ollama API is accessible")
            print(f"Version: {response.json()}")
        else:
            print(f"❌ Ollama API returned status {response.status_code}")
            return False

        # Test list models
        response = requests.get("http://localhost:11434/api/tags")
        if response.status_code == 200:
            models = response.json().get("models", [])
            print(f"✅ Found {len(models)} models:")
            for model in models:
                print(f"  • {model['name']} ({model['size']} bytes)")

        # Test chat completion
        test_prompt = {
            "model": "qwen2.5-coder:7b",
            "messages": [
                {"role": "user", "content": "Hello! Just testing the connection."}
            ],
            "stream": False,
        }

        response = requests.post(
            "http://localhost:11434/api/chat", json=test_prompt, timeout=30
        )

        if response.status_code == 200:
            result = response.json()
            print("✅ Chat API working")
            print(f"Response: {result['message']['content'][:100]}...")
        else:
            print(f"❌ Chat API failed with status {response.status_code}")

        return True

    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to Ollama API at localhost:11434")
        print("Make sure Ollama is running: sudo systemctl start ollama")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False


if __name__ == "__main__":
    print("🦙 Testing Ollama API Connection...")
    test_ollama_connection()
