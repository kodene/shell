Vim�UnDo� �	M�NjD̖�iL�ċr�j��--�   O                  	       	   	   	    TV��    _�                             ����                                                                                                                                                                                                                                                                                                                                                  v        TV��     �                7use WSB::Types qw( Uri SoftwareBuild SoftwareFeature );�                >use List::Objects::Types qw( TypedArray ImmutableTypedArray );�                #use Types::Standard qw( Str Enum );5�_�                            ����                                                                                                                                                                                                                                                                                                                                                  v        TV��     �                use Moo;5�_�                            ����                                                                                                                                                                                                                                                                                                                                                  v        TV��     �      	          with 'Software::StateRole';5�_�                    	        ����                                                                                                                                                                                                                                                                                                                                                  v        TV��     �      
          use namespace::clean;5�_�                            ����                                                                                                                                                                                                                                                                                                                                                  v        TV��     �                );�                    coerce => 1,�                    isa    => Uri,�                    is     => 'ro',�                has 'uri' => (�                 �                -has 'archive' => ( is => 'ro', isa => Str, );�                 �                );�                    required => 1,�                    isa      => Str,�                    is       => 'ro',�                /has ['short_name', 'full_name', 'version'] => (5�_�                            ����                                                                                                                                                                                                                                                                                                                                                  v        TV�C     �                 );�                "    predicate => 'has_dependency',�                6    coerce    => 1, # Required for ImmutableTypedArray�                *    isa       => ImmutableTypedArray[Str],�                    is        => 'ro',�                has 'dependencies' => (5�_�                            ����                                                                                                                                                                                                                                                                                                                                                  v        TV�D     �                 5�_�      	                       ����                                                                                                                                                                                                                                                                                                                                        &           v        TV��     �   %   '           �   $   &          );�   #   %              required => 1,�   "   $          ;    isa      => Enum[@{WSB::Config->instance->categories}],�   !   #              is       => 'ro',�       "          has 'category' => (�      !           5�_�                  	   '        ����                                                                                                                                                                                                                                                                                                                            '           ,           v        TV��    �   +   -           �   *   ,          );�   )   +              required => 1,�   (   *          6    isa      => Enum[@{WSB::Config->instance->types}],�   '   )              is       => 'ro',�   &   (          has 'type' => (5��