import { useLocation } from 'react-router-dom';
import { useEffect, useState } from 'react';
import axios from 'axios';

function JsonData() {
  // const { userId } = useParams();
  const location = useLocation();
  const [data, setData] = useState('Loading...');

  useEffect(() => {
    axios.get(location.pathname)
      .then(res => setData(JSON.stringify(res.data, null, 2)))
      .catch(err => setData(JSON.stringify(err.response?.data || err.message, null, 2)));
  }, [location.pathname]);

  return <pre>{data}</pre>;
}

export default JsonData;