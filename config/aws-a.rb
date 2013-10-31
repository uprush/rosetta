def configured_role
  {
    # "broker"     => ["localhost"] # we use ElastiCache Redis, so chef provision is not required
    "agent"        => ["172.31.8.104", "172.31.51.144"]
    "indexer"      => ["localhost"],
    "dashboard"    => ["localhost"],
    "filter"       => ["localhost"]
  }
end
