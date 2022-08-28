#!/Users/brian/bin/perls/perl-latest
use v5.26;
use experimental qw(signatures);
no warnings qw(experimental::signatures);

use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Util qw(dumper);
use Time::Moment;

# http://bustime.mta.info/wiki/Developers/SIRIIntro
# http://bustime.mta.info/wiki/Developers/OneBusAwayRESTfulAPI

my $APIKEY = $ENV{MTA_BUSTIME_API_KEY};
my $stop   = $ARGV[0] // $ENV{MTA_BUSTIME_HOME_STOP};

my $ua = Mojo::UserAgent->new;

# http://bustime.mta.info/api/where/stop/MTA_123456.json?key=...
# http://bustime.mta.info/api/siri/vehicle-monitoring.json?key=...

my $path = 'stop-monitoring.json';

my %hash = (
	key           => $APIKEY,
	version       => 2,
	OperatorRef   => 'MTA',
	MonitoringRef => $stop,
	);

my $url = Mojo::URL->new( "http://bustime.mta.info/api/siri/$path" );


my $tx = $ua->get( $url, form => \%hash );

my $perl = $tx->res->json;

my $stuff = $perl->{'Siri'}{'ServiceDelivery'}{'StopMonitoringDelivery'}[0];
my $now  = $stuff->{'ResponseTimestamp'};

my @buses =
	map { $_->{"MonitoredVehicleJourney"}{"MonitoredCall"} }
	$stuff->{'MonitoredStopVisit'}->@*; # array of hashes

my $first_bus   = $perl->{'Siri'}{'ServiceDelivery'}{'StopMonitoringDelivery'}[0]{'MonitoredStopVisit'}[0]{'MonitoredVehicleJourney'};
my $stop_name   = $first_bus->{'MonitoredCall'}{'StopPointName'}[0];
my $route_name  = $first_bus->{'PublishedLineName'}[0];
my $destination = $first_bus->{'DestinationName'}[0];

my $header = "$route_name - $stop_name to $destination ($stop)";
my $ruler = '-' x length($header);
say "$header\n$ruler";
foreach my $bus ( @buses ) {
	my $arrival  = $bus->{'ExpectedArrivalTime'};
	my $distance = $bus->{'ArrivalProximityText'};
	my $stops    = $bus->{'NumberOfStopsAway'};
	my( $quant, $unit ) = $distance =~ /(\d+(?:.\d+)?) \s+ (\S+) \s+ (.*) /x;

	my $relative_time = $arrival ? time_diff( $now, $arrival ) . ' minutes' : '';
	say "$stops stops - $relative_time";
	}

sub time_diff ( $now, $arrival ) {
	my $tm_now = Time::Moment->from_string($now);
	my $tm_arrival = Time::Moment->from_string($arrival);

	my $minutes = $tm_now->delta_minutes($tm_arrival);
	}


__END__

  "Siri" => {
    "ServiceDelivery" => {
      "ResponseTimestamp" => "2018-02-27T07:37:29.995-05:00",
      "SituationExchangeDelivery" => [],
      "StopMonitoringDelivery" => [
        {
          "MonitoredStopVisit" => [
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "43.994915",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_23940_B63-114",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-041900_B63_114"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' ),
                "MonitoredCall" => {
                  "ArrivalProximityText" => "1.8 miles away",
                  "DistanceFromStop" => 2844,
                  "ExpectedArrivalTime" => "2018-02-27T07:54:44.493-05:00",
                  "ExpectedDepartureTime" => "2018-02-27T07:54:44.493-05:00",
                  "NumberOfStopsAway" => 13,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.655674",
                  "Longitude" => "-73.99933"
                },
                "VehicleRef" => "MTA NYCT_774"
              },
              "RecordedAtTime" => "2018-02-27T07:37:08.000-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "43.719383",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_15000_B63-106",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-042600_B63_106"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "2.4 miles away",
                  "DistanceFromStop" => 3815,
                  "ExpectedArrivalTime" => "2018-02-27T08:00:48.555-05:00",
                  "ExpectedDepartureTime" => "2018-02-27T08:00:48.555-05:00",
                  "NumberOfStopsAway" => 17,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.648811",
                  "Longitude" => "-74.006463"
                },
                "VehicleRef" => "MTA NYCT_257"
              },
              "RecordedAtTime" => "2018-02-27T07:37:26.000-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "67.59361",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_24780_B63-115",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-043300_B63_115"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "4.2 miles away",
                  "DistanceFromStop" => 6764,
                  "ExpectedArrivalTime" => "2018-02-27T08:21:13.285-05:00",
                  "ExpectedDepartureTime" => "2018-02-27T08:21:13.285-05:00",
                  "NumberOfStopsAway" => 31,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.626322",
                  "Longitude" => "-74.02393"
                },
                "VehicleRef" => "MTA NYCT_796"
              },
              "RecordedAtTime" => "2018-02-27T07:37:16.000-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "49.417",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_16800_B63-107",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-045100_B63_107"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "4.7 miles away",
                  "DistanceFromStop" => 7548,
                  "ExpectedArrivalTime" => "2018-02-27T08:25:46.342-05:00",
                  "ExpectedDepartureTime" => "2018-02-27T08:25:46.342-05:00",
                  "NumberOfStopsAway" => 35,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.61991",
                  "Longitude" => "-74.027576"
                },
                "VehicleRef" => "MTA NYCT_430"
              },
              "RecordedAtTime" => "2018-02-27T07:36:58.000-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "56.5687",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_23220_B63-111",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-049400_B63_111"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "6.0 miles away",
                  "DistanceFromStop" => 9581,
                  "NumberOfStopsAway" => 45,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginAimedDepartureTime" => "2018-02-27T08:14:00.000-05:00",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "ProgressStatus" => [
                  "prevTrip"
                ],
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.614124",
                  "Longitude" => "-74.035053"
                },
                "VehicleRef" => "MTA NYCT_334"
              },
              "RecordedAtTime" => "2018-02-27T07:37:03.408-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "229.27051",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_18600_B63-108",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-048200_B63_108"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "6.2 miles away",
                  "DistanceFromStop" => 9952,
                  "NumberOfStopsAway" => 46,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginAimedDepartureTime" => "2018-02-27T08:02:00.000-05:00",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "ProgressStatus" => [
                  "prevTrip"
                ],
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.618339",
                  "Longitude" => "-74.02892"
                },
                "VehicleRef" => "MTA NYCT_261"
              },
              "RecordedAtTime" => "2018-02-27T07:37:00.000-05:00"
            },
            {
              "MonitoredVehicleJourney" => {
                "Bearing" => "223.82718",
                "BlockRef" => "MTA NYCT_JG_A8-Weekday-SDon_E_JG_23340_B63-112",
                "DestinationName" => [
                  "PIER 6 BKLYN BRIDGE PK via 5 AV"
                ],
                "DestinationRef" => "MTA_801007",
                "DirectionRef" => 0,
                "FramedVehicleJourneyRef" => {
                  "DataFrameRef" => "2018-02-27",
                  "DatedVehicleJourneyRef" => "MTA NYCT_JG_A8-Weekday-SDon-050600_B63_112"
                },
                "JourneyPatternRef" => "MTA_B630144",
                "LineRef" => "MTA NYCT_B63",
                "Monitored" => $VAR1->{"Siri"}{"ServiceDelivery"}{"StopMonitoringDelivery"}[0]{"MonitoredStopVisit"}[0]{"MonitoredVehicleJourney"}{"Monitored"},
                "MonitoredCall" => {
                  "ArrivalProximityText" => "9.3 miles away",
                  "DistanceFromStop" => 14916,
                  "NumberOfStopsAway" => 68,
                  "StopPointName" => [
                    "5 AV/UNION ST"
                  ],
                  "StopPointRef" => "MTA_308209",
                  "VisitNumber" => 1
                },
                "OperatorRef" => "MTA NYCT",
                "OriginAimedDepartureTime" => "2018-02-27T06:54:00.000-05:00",
                "OriginRef" => "MTA_306619",
                "ProgressRate" => "normalProgress",
                "ProgressStatus" => [
                  "prevTrip"
                ],
                "PublishedLineName" => [
                  "B63"
                ],
                "SituationRef" => [],
                "VehicleLocation" => {
                  "Latitude" => "40.656035",
                  "Longitude" => "-73.998955"
                },
                "VehicleRef" => "MTA NYCT_375"
              },
              "RecordedAtTime" => "2018-02-27T07:37:00.000-05:00"
            }
          ],
          "ResponseTimestamp" => "2018-02-27T07:37:29.995-05:00",
          "ValidUntil" => "2018-02-27T07:38:29.995-05:00"
        }
      ]
    }
  }
}



key - your MTA Bus Time developer API key (required).  Go here to get one.
version - which version of the SIRI API to use (1 or 2). Defaults to 1, but 2 is preferrable.
OperatorRef - the GTFS agency ID to be monitored (optional).  Currently, all stops have operator/agency ID of MTA. If left out, the system will make a best guess. Usage of the OperatorRef is suggested, as calls will return faster when populated.
MonitoringRef - the GTFS stop ID of the stop to be monitored (required).  For example, 308214 for the stop at 5th Avenue and Union St towards Bay Ridge.
LineRef - a filter by 'fully qualified' route name, GTFS agency ID + route ID (e.g. MTA NYCT_B63).
DirectionRef - a filter by GTFS direction ID (optional).  Either 0 or 1.
StopMonitoringDetailLevel - Level of detail present in response. In order of verbosity:
	minimum - only available in version 2. Designed for front-end use.
	basic - only available in version 2. Designed for system-to-system interchange when GTFS is loaded.
	normal - default.
	calls Determines whether or not the response will include the stops ("calls" in SIRI-speak) each vehicle is going to make after it serves the selected stop (optional).
MaximumNumberOfCallsOnwards - Limits the number of OnwardCall elements returned in the query.
MaximumStopVisits - an upper bound on the number of buses to return in the results.
MinimumStopVisitsPerLine - a lower bound on the number of buses to return in the results per line/route (assuming that many are available)
