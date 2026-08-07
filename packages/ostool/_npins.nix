{self, }
version =
          if self ? rev
          then self.shortRev
          else "dirty";