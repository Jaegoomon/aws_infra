[
  {
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "command": [
      "python",
      "-m",
      "http.server",
      "80"
    ],
    "cpu": 10,
    "memory": 300,
    "image": "python:3.9-slim",
    "name": "simple-python-app"
  }
]