import { post, get } from '@rails/request.js'

export function blockingJob(options) {
  const url = options.url
  blockUi()
  return new Promise((resolve, reject) => {
    const jobPromise = post(url, { body: JSON.stringify(options.params || {})})
    jobPromise.then(response => {
      if (response.ok) {
        response.json.then(json => {
          const job_id = json.job_id
          pollJob(job_id, resolve, reject)
        })
      } else {
        reject({ status: 'error' })
      }
    })
  })
}

function pollJob(job_id, resolve, reject) {
  const pollPromise = get('/blocking_jobs/' + job_id)
    pollPromise.then(response => {
    if (response.ok) {
      response.json.then(json => {
        if (json.job.finished_at) {
          unblockUi()
          resolve( {status:'success'} )
        } else {
          setTimeout(pollJob.bind(null, job_id, resolve, reject), 1000)
        }
      })
    } else {
      unblockUi()
      reject( { status: 'error' } )
    }
  })
}

function blockUi() {
  const overlay = document.createElement('div')
    overlay.id = 'global-loading-overlay'
    overlay.innerHTML = `
      <div class="loading-spinner">Loading...</div>
    `
    Object.assign(overlay.style, {
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'rgba(255, 255, 255, 0.8)',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      zIndex: 9999,
    })

    const spinner = overlay.querySelector('.loading-spinner')
    Object.assign(spinner.style, {
      padding: '1em 2em',
      background: '#000',
      color: '#fff',
      borderRadius: '8px',
      fontSize: '1.2em',
    })

    document.body.appendChild(overlay)
}

function unblockUi() {
  const overlay = document.getElementById('global-loading-overlay')
  if (overlay) {
    document.body.removeChild(overlay)
  }
}

