import { Routes, Route } from 'react-router-dom';
import AppShell from './components/layout/AppShell';
import Dashboard from './pages/Dashboard';

// Placeholder components for routes that don't exist yet to prevent build errors
const Equipment = () => <div className="p-8 text-slate-500">Equipment Management Module (Coming Soon)</div>;
const Bookings = () => <div className="p-8 text-slate-500">Booking Calendar Module (Coming Soon)</div>;
const Experiments = () => <div className="p-8 text-slate-500">Experiment Tracking Module (Coming Soon)</div>;
const Team = () => <div className="p-8 text-slate-500">Team Collaboration Module (Coming Soon)</div>;
const Settings = () => <div className="p-8 text-slate-500">System Settings Module (Coming Soon)</div>;

function App() {
  return (
    <Routes>
      <Route path="/" element={<AppShell />}>
        <Route index element={<Dashboard />} />
        <Route path="equipment" element={<Equipment />} />
        <Route path="bookings" element={<Bookings />} />
        <Route path="experiments" element={<Experiments />} />
        <Route path="team" element={<Team />} />
        <Route path="settings" element={<Settings />} />
      </Route>
    </Routes>
  );
}

export default App;
