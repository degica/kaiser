{
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p51s6jrbj94ps1ywyibrizbcc401khb86zdz9sq85gcs20my1bf";
      type = "gem";
    };
    version = "5.2.1.1";
  };
  aruba = {
    dependencies = ["childprocess" "contracts" "cucumber" "ffi" "rspec-expectations" "thor"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11v7d4d3q1as3w5md22q3vilnmqw1icp7sg955ylfzmxjc07pdby";
      type = "gem";
    };
    version = "0.14.6";
  };
  aruba-doubles = {
    dependencies = ["cucumber" "rspec"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qd6f9y6pgnr44x92988dmika0x3icmgfm35fxzg75390jr0qill";
      type = "gem";
    };
    version = "1.2.1";
  };
  aruba-rspec = {
    dependencies = ["aruba" "aruba-doubles" "rspec"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j355qp8m7wxwkrbfyhkhdj08mgal92h7xfyxvdg1fvzfdf37fdn";
      type = "gem";
    };
    version = "1.0.1";
  };
  backports = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hshjxww2h7s0dk57njrygq4zpp0nlqrjfya7zwm27iq3rhc3y8g";
      type = "gem";
    };
    version = "3.11.4";
  };
  builder = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qibi5s67lpdv1wgcj66wcymcr04q6j4mzws6a479n0mlrmh5wr1";
      type = "gem";
    };
    version = "3.2.3";
  };
  bundix = {
    dependencies = [];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yahi5vzjgcrma5xxdcaf1pqsa9qggz8yylv8pgpbjhc07nc8n7y";
      type = "gem";
    };
    version = "2.5.0";
  };
  childprocess = {
    dependencies = ["ffi"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a61922kmvcxyj5l70fycapr87gz1dzzlkfpq85rfqk5vdh3d28p";
      type = "gem";
    };
    version = "0.9.0";
  };
  concurrent-ruby = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18q9skp5pfq4jwbxzmw8q2rn4cpw6mf4561i2hsjcl1nxdag2jvb";
      type = "gem";
    };
    version = "1.1.3";
  };
  contracts = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "119f5p1n6r5svbx8h09za6a4vrsnj5i1pzr9cqdn9hj3wrxvyl3a";
      type = "gem";
    };
    version = "0.16.0";
  };
  cucumber = {
    dependencies = ["builder" "cucumber-core" "cucumber-expressions" "cucumber-wire" "diff-lcs" "gherkin" "multi_json" "multi_test"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s2brssrpal8hyhcgg974x3xyhpmvpwps5ypd9p8w2lg01l1pp3j";
      type = "gem";
    };
    version = "3.1.2";
  };
  cucumber-core = {
    dependencies = ["backports" "cucumber-tag_expressions" "gherkin"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iavlh8hqj9lwljbpkw06259gdicbr1bdb6pbj5yy3n8szgr8k3c";
      type = "gem";
    };
    version = "3.2.1";
  };
  cucumber-expressions = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zwmv6hznyz9vk81f5dhwcr9jhxx2vmbk8yyazayvllvhy0fkpdw";
      type = "gem";
    };
    version = "6.0.1";
  };
  cucumber-tag_expressions = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cvmbljybws0qzjs1l67fvr9gqr005l8jk1ni5gcsis9pfmqh3vc";
      type = "gem";
    };
    version = "1.1.1";
  };
  cucumber-wire = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09ymvqb0sbw2if1nxg8rcj33sf0va88ancq5nmp8g01dfwzwma2f";
      type = "gem";
    };
    version = "0.0.1";
  };
  diff-lcs = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18w22bjz424gzafv6nzv98h0aqkwz3d9xhm7cbr1wfbyas8zayza";
      type = "gem";
    };
    version = "1.3";
  };
  factory_bot = {
    dependencies = ["activesupport"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13q1b7imb591068plg4ashgsqgzarvfjz6xxn3jk6klzikz5zhg1";
      type = "gem";
    };
    version = "4.11.1";
  };
  ffi = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jpm2dis1j7zvvy3lg7axz9jml316zrn7s0j59vyq3qr127z0m7q";
      type = "gem";
    };
    version = "1.9.25";
  };
  gherkin = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cgcdchwwdm10rsk44frjwqd4ihprhxjbm799nscqy2q1raqfj5s";
      type = "gem";
    };
    version = "5.1.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gcp1m1p6dpasycfz2sj82ci9ggz7lsskz9c9q6gvfwxrl8y9dx7";
      type = "gem";
    };
    version = "1.1.1";
  };
  kaiser = {
    dependencies = ["optimist"];
    groups = ["default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "maglev";
    } {
      engine = "maglev";
      version = "1.8";
    } {
      engine = "maglev";
      version = "1.8";
    } {
      engine = "maglev";
      version = "1.9";
    } {
      engine = "maglev";
      version = "1.9";
    } {
      engine = "maglev";
      version = "2.0";
    } {
      engine = "maglev";
      version = "2.0";
    } {
      engine = "maglev";
      version = "2.1";
    } {
      engine = "maglev";
      version = "2.1";
    } {
      engine = "maglev";
      version = "2.2";
    } {
      engine = "maglev";
      version = "2.2";
    } {
      engine = "maglev";
      version = "2.3";
    } {
      engine = "maglev";
      version = "2.3";
    } {
      engine = "maglev";
      version = "2.4";
    } {
      engine = "maglev";
      version = "2.4";
    } {
      engine = "maglev";
      version = "2.5";
    } {
      engine = "maglev";
      version = "2.5";
    } {
      engine = "maglev";
      version = "2.6";
    } {
      engine = "maglev";
      version = "2.6";
    } {
      engine = "rbx";
    } {
      engine = "rbx";
    } {
      engine = "rbx";
      version = "1.8";
    } {
      engine = "rbx";
      version = "1.9";
    } {
      engine = "rbx";
      version = "2.0";
    } {
      engine = "rbx";
      version = "2.1";
    } {
      engine = "rbx";
      version = "2.2";
    } {
      engine = "rbx";
      version = "2.3";
    } {
      engine = "rbx";
      version = "2.4";
    } {
      engine = "rbx";
      version = "2.5";
    } {
      engine = "rbx";
      version = "2.6";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
      version = "1.8";
    } {
      engine = "ruby";
      version = "1.8";
    } {
      engine = "ruby";
      version = "1.9";
    } {
      engine = "ruby";
      version = "1.9";
    } {
      engine = "ruby";
      version = "2.0";
    } {
      engine = "ruby";
      version = "2.0";
    } {
      engine = "ruby";
      version = "2.1";
    } {
      engine = "ruby";
      version = "2.1";
    } {
      engine = "ruby";
      version = "2.2";
    } {
      engine = "ruby";
      version = "2.2";
    } {
      engine = "ruby";
      version = "2.3";
    } {
      engine = "ruby";
      version = "2.3";
    } {
      engine = "ruby";
      version = "2.4";
    } {
      engine = "ruby";
      version = "2.4";
    } {
      engine = "ruby";
      version = "2.5";
    } {
      engine = "ruby";
      version = "2.5";
    } {
      engine = "ruby";
      version = "2.6";
    } {
      engine = "ruby";
      version = "2.6";
    }];
    source = {
      path = ./.;
      type = "path";
    };
    version = "0.4.107";
  };
  minitest = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0icglrhghgwdlnzzp4jf76b0mbc71s80njn5afyfjn4wqji8mqbq";
      type = "gem";
    };
    version = "5.11.3";
  };
  multi_json = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  multi_test = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sx356q81plr67hg16jfwz9hcqvnk03bd9n75pmdw8pfxjfy1yxd";
      type = "gem";
    };
    version = "0.1.2";
  };
  optimist = {
    groups = ["default"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "maglev";
    } {
      engine = "maglev";
      version = "1.8";
    } {
      engine = "maglev";
      version = "1.8";
    } {
      engine = "maglev";
      version = "1.9";
    } {
      engine = "maglev";
      version = "1.9";
    } {
      engine = "maglev";
      version = "2.0";
    } {
      engine = "maglev";
      version = "2.0";
    } {
      engine = "maglev";
      version = "2.1";
    } {
      engine = "maglev";
      version = "2.1";
    } {
      engine = "maglev";
      version = "2.2";
    } {
      engine = "maglev";
      version = "2.2";
    } {
      engine = "maglev";
      version = "2.3";
    } {
      engine = "maglev";
      version = "2.3";
    } {
      engine = "maglev";
      version = "2.4";
    } {
      engine = "maglev";
      version = "2.4";
    } {
      engine = "maglev";
      version = "2.5";
    } {
      engine = "maglev";
      version = "2.5";
    } {
      engine = "maglev";
      version = "2.6";
    } {
      engine = "maglev";
      version = "2.6";
    } {
      engine = "rbx";
    } {
      engine = "rbx";
    } {
      engine = "rbx";
      version = "1.8";
    } {
      engine = "rbx";
      version = "1.9";
    } {
      engine = "rbx";
      version = "2.0";
    } {
      engine = "rbx";
      version = "2.1";
    } {
      engine = "rbx";
      version = "2.2";
    } {
      engine = "rbx";
      version = "2.3";
    } {
      engine = "rbx";
      version = "2.4";
    } {
      engine = "rbx";
      version = "2.5";
    } {
      engine = "rbx";
      version = "2.6";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
    } {
      engine = "ruby";
      version = "1.8";
    } {
      engine = "ruby";
      version = "1.8";
    } {
      engine = "ruby";
      version = "1.9";
    } {
      engine = "ruby";
      version = "1.9";
    } {
      engine = "ruby";
      version = "2.0";
    } {
      engine = "ruby";
      version = "2.0";
    } {
      engine = "ruby";
      version = "2.1";
    } {
      engine = "ruby";
      version = "2.1";
    } {
      engine = "ruby";
      version = "2.2";
    } {
      engine = "ruby";
      version = "2.2";
    } {
      engine = "ruby";
      version = "2.3";
    } {
      engine = "ruby";
      version = "2.3";
    } {
      engine = "ruby";
      version = "2.4";
    } {
      engine = "ruby";
      version = "2.4";
    } {
      engine = "ruby";
      version = "2.5";
    } {
      engine = "ruby";
      version = "2.5";
    } {
      engine = "ruby";
      version = "2.6";
    } {
      engine = "ruby";
      version = "2.6";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05jxrp3nbn5iilc1k7ir90mfnwc5abc9h78s5rpm3qafwqxvcj4j";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jcabbgnjc788chx31sihc5pgbqnlc1c75wakmqlbjdm8jns2m9b";
      type = "gem";
    };
    version = "10.5.0";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15ppasvb9qrscwlyjz67ppw1lnxiqnkzx5vkx1bd8x5n3dhikxc3";
      type = "gem";
    };
    version = "3.8.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p1s5bnbqp3sxk67y0fh0x884jjym527r0vgmhbm81w7aq6b7l4p";
      type = "gem";
    };
    version = "3.8.0";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18l21hy1zdc2pgc2yb17k3n2al1khpfr0z6pijlm852iz6vj0dkm";
      type = "gem";
    };
    version = "3.8.2";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06y508cjqycb4yfhxmb3nxn0v9xqf17qbd46l1dh4xhncinr4fyp";
      type = "gem";
    };
    version = "3.8.0";
  };
  rspec-support = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p3m7drixrlhvj2zpc38b11x145bvm311x6f33jjcxmvcm0wq609";
      type = "gem";
    };
    version = "3.8.0";
  };
  thor = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
  thread_safe = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tzinfo = {
    dependencies = ["thread_safe"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fjx9j327xpkkdlxwmkl3a8wqj7i4l4jwlrv3z13mg95z9wl253z";
      type = "gem";
    };
    version = "1.2.5";
  };
}