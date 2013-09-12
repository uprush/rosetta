def configured_role
  {
    # "broker"     => ["localhost"] # we use ElastiCache Redis, so chef provision is not required
    "agent"        => ["172.31.63.61", "172.31.51.144"]
  }
end
