import { useEffect, useState } from "react";
const apiUrl = process.env.REACT_APP_API_URL;

function App() {
  const [message, setMessage] = useState("");
  useEffect(() => {
    fetch(`${apiUrl}/api/message`)
      .then((res) => res.json())
      .then((data) => setMessage(data.message));
  }, []);
  return (
    <div>
      <h1>Frontend</h1>
      <p>Message from backend: {message}</p>
    </div>
  );
}

export default App;
