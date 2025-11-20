# Suppress info logs to reduce test output noise
Logger.configure(level: :error)

ExUnit.start()
ExUnit.configure(colors: [enabled: true])
