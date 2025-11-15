// ./web/src/utils/api.js

const API_BASE = 'http://localhost:3001'

const defaultOptions = {
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  }
}

async function handleResponse(response) {
  // Handle 204 No Content responses
  if (response.status === 204) {
    return null
  }

  // Parse the response body
  const contentType = response.headers.get('content-type')
  
  // Check if response is JSON
  if (!contentType || !contentType.includes('application/json')) {
    const text = await response.text()
    console.error('Non-JSON response:', text)
    throw new Error(`Expected JSON but got ${contentType}`)
  }

  const data = await response.json()

  // If response is not ok, throw error with parsed data
  if (!response.ok) {
    const error = new Error(data.error?.detail || data.message || response.statusText)
    error.status = response.status
    error.data = data
    throw error
  }

  return data
}

export const api = {
  async get(url, options = {}) {
    const fullUrl = API_BASE + url
    const response = await fetch(fullUrl, {
      ...defaultOptions,
      ...options
    })
    return handleResponse(response)
  },

  async post(url, data, options = {}) {
    const response = await fetch(url, {
      method: 'POST',
      ...defaultOptions,
      body: JSON.stringify(data),
      ...options
    })
    return handleResponse(response)
  },

  async put(url, data, options = {}) {
    const response = await fetch(url, {
      method: 'PUT',
      ...defaultOptions,
      body: JSON.stringify(data),
      ...options
    })
    return handleResponse(response)
  },

  async patch(url, data, options = {}) {
    const response = await fetch(url, {
      method: 'PATCH',
      ...defaultOptions,
      body: JSON.stringify(data),
      ...options
    })
    return handleResponse(response)
  },

  async delete(url, options = {}) {
    const response = await fetch(url, {
      method: 'DELETE',
      ...defaultOptions,
      ...options
    })
    return handleResponse(response)
  }
}