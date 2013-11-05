def configured_role
  {
    # "broker"     => ["localhost"] # we use ElastiCache Redis, so chef provision is not required
    "agent"        => ["172.31.11.76", "172.31.11.77"],
    "indexer"      => ["172.31.13.121"],
    "dashboard"    => ["172.31.0.101"],
    "filter"       => ["172.31.10.128"]
  }
end
