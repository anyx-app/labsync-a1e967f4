import { 
  ArrowUpRight, 
  FlaskConical, 
  Microscope, 
  Clock, 
  AlertCircle,
  CalendarCheck,
  Activity
} from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const data = [
  { name: 'Mon', experiments: 4, bookings: 2 },
  { name: 'Tue', experiments: 3, bookings: 5 },
  { name: 'Wed', experiments: 7, bookings: 4 },
  { name: 'Thu', experiments: 5, bookings: 8 },
  { name: 'Fri', experiments: 9, bookings: 6 },
  { name: 'Sat', experiments: 2, bookings: 1 },
  { name: 'Sun', experiments: 1, bookings: 0 },
];

export default function Dashboard() {
  return (
    <div className="space-y-8 p-8 max-w-7xl mx-auto">
      {/* Welcome Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Lab Overview</h1>
          <p className="text-slate-500 mt-1">Welcome back, Dr. Vance. Here's what's happening today.</p>
        </div>
        <div className="flex gap-3">
          <button className="px-4 py-2 bg-white border border-slate-200 text-slate-700 font-medium rounded-lg hover:bg-slate-50 hover:border-slate-300 transition-all flex items-center gap-2">
            <CalendarCheck className="w-4 h-4" />
            Schedule
          </button>
          <button className="px-4 py-2 bg-[#0057A7] text-white font-medium rounded-lg hover:bg-[#004482] shadow-sm shadow-blue-500/20 transition-all flex items-center gap-2">
            <FlaskConical className="w-4 h-4" />
            New Experiment
          </button>
        </div>
      </div>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[
          { label: 'Active Experiments', value: '12', trend: '+2', icon: FlaskConical, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: 'Equipment In Use', value: '8/24', trend: '33%', icon: Microscope, color: 'text-emerald-600', bg: 'bg-emerald-50' },
          { label: 'Upcoming Bookings', value: '5', trend: 'Today', icon: Clock, color: 'text-violet-600', bg: 'bg-violet-50' },
          { label: 'Maintenance Alerts', value: '1', trend: 'Urgent', icon: AlertCircle, color: 'text-amber-600', bg: 'bg-amber-50' },
        ].map((stat) => (
          <div key={stat.label} className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all group">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm font-medium text-slate-500">{stat.label}</p>
                <h3 className="text-2xl font-bold text-slate-900 mt-2">{stat.value}</h3>
              </div>
              <div className={`p-3 rounded-lg ${stat.bg}`}>
                <stat.icon className={`w-5 h-5 ${stat.color}`} />
              </div>
            </div>
            <div className="mt-4 flex items-center gap-2 text-sm">
              <span className="flex items-center text-emerald-600 font-medium bg-emerald-50 px-2 py-0.5 rounded-full">
                <ArrowUpRight className="w-3 h-3 mr-1" />
                {stat.trend}
              </span>
              <span className="text-slate-400">vs last week</span>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Chart Section */}
        <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="font-semibold text-slate-900 flex items-center gap-2">
                <Activity className="w-4 h-4 text-slate-400" />
                Lab Activity
              </h3>
              <p className="text-sm text-slate-500">Experiment scheduling vs execution</p>
            </div>
            <select className="text-sm border-slate-200 rounded-md focus:ring-blue-500 focus:border-blue-500">
              <option>This Week</option>
              <option>Last Week</option>
            </select>
          </div>
          <div className="h-80 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data}>
                <defs>
                  <linearGradient id="colorExp" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0057A7" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#0057A7" stopOpacity={0}/>
                  </linearGradient>
                  <linearGradient id="colorBook" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00AEEF" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#00AEEF" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #E2E8F0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  itemStyle={{ fontSize: '12px', fontWeight: 500 }}
                />
                <Area type="monotone" dataKey="experiments" stroke="#0057A7" strokeWidth={2} fillOpacity={1} fill="url(#colorExp)" />
                <Area type="monotone" dataKey="bookings" stroke="#00AEEF" strokeWidth={2} fillOpacity={1} fill="url(#colorBook)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Activity Feed */}
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
          <h3 className="font-semibold text-slate-900 mb-6">Recent Updates</h3>
          <div className="space-y-6">
            {[
              { title: 'Centrifuge C-200 Maintenance', time: '2h ago', user: 'Mike Chen', type: 'maintenance' },
              { title: 'PCR Protocol v2.1 Update', time: '4h ago', user: 'Sarah Miller', type: 'protocol' },
              { title: 'New Booking: Microscope A', time: '5h ago', user: 'Dr. Vance', type: 'booking' },
              { title: 'Experiment "Cell Growth" Complete', time: '1d ago', user: 'Lab Bot', type: 'system' },
            ].map((item, i) => (
              <div key={i} className="flex gap-4 group">
                <div className="relative">
                  <div className={`w-2 h-2 mt-2 rounded-full ring-4 ring-white ${
                    item.type === 'maintenance' ? 'bg-amber-500' : 
                    item.type === 'protocol' ? 'bg-blue-500' :
                    item.type === 'booking' ? 'bg-emerald-500' : 'bg-slate-400'
                  }`} />
                  {i !== 3 && <div className="absolute top-4 left-1 w-0.5 h-full bg-slate-100 -z-10" />}
                </div>
                <div>
                  <p className="text-sm font-medium text-slate-900 group-hover:text-blue-600 transition-colors cursor-pointer">{item.title}</p>
                  <p className="text-xs text-slate-500 mt-0.5">{item.user} • {item.time}</p>
                </div>
              </div>
            ))}
          </div>
          <button className="w-full mt-6 py-2 text-sm text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-lg transition-all border border-transparent hover:border-slate-200">
            View All Activity
          </button>
        </div>
      </div>
    </div>
  );
}
