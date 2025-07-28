import reactLogo from "./assets/react.svg";
import { useNoir } from "./useNoir";
import viteLogo from "/vite.svg";
import "./App.css";

function App() {
  const { logs, proof, onSubmit } = useNoir();

  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Age Verification</h1>
      <div className="card">
        <input id="age" type="number" placeholder="Enter age" />
        <button className="submit" id="submit" type="button" onClick={onSubmit}>
          Submit
        </button>
      </div>

      <div className="outer">
        <div id="logs" className="inner">
          <h2>Logs</h2>
          {logs.map((log) => (
            <div key={log.key}>{log.text}</div>
          ))}
        </div>
        <div id="results" className="inner">
          <h2>Proof</h2>
          {proof && <div>{proof}</div>}
        </div>
      </div>
    </>
  );
}

export default App;
