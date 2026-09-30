using System;
using System.Linq;
using System.Numerics;
using System.Text;
using Valve.VR;
using OscJack;

namespace milkydelta.OscVR;

class Program
{
    static CVRSystem vrSystem = null;

    static StringBuilder sb = new StringBuilder(512);
    static TrackedDevicePose_t[] poseArray = new TrackedDevicePose_t[OpenVR.k_unMaxTrackedDeviceCount];
    static TrackedDevicePose_t[] oldposeArray = new TrackedDevicePose_t[OpenVR.k_unMaxTrackedDeviceCount];
    static string[] serialArray = new string[OpenVR.k_unMaxTrackedDeviceCount];

    static OscClient osc;

    static string dest = "127.0.0.1";
    static int port = 27769;
    static int rate = 90;
    static int verbose=0;

    static Int64 count=0;

    static void InitialiseOpenVR()
    {
        EVRApplicationType appType = EVRApplicationType.VRApplication_Background;
        EVRInitError err = EVRInitError.None;

        Console.WriteLine($"Initialising OpenVR as {appType.ToString()}");
        vrSystem = OpenVR.Init(ref err, appType);
        if (err != EVRInitError.None)
        {
            Console.WriteLine($"Could not initialise OpenVR. Error: {err.ToString()}");
            Environment.Exit(-1);
        }

        Console.WriteLine("OpenVR runtime version: " + vrSystem.GetRuntimeVersion());
    }

    static void Main(string[] args)
    {
        var op = new Mono.Options.OptionSet()
        {
            {"port=", "Destination OSC port", v => Int32.TryParse(v, out port)},
            {"rate=", "Frequency at which OpenVR is polled for new poses", v => Int32.TryParse(v, out rate)},
            {"v", v => verbose++}
        };

        try
        {
            var unk = op.Parse(args);
        }
        catch (Mono.Options.OptionException e)
        {
            Console.WriteLine("OptionException: " + e.Message);
            op.WriteOptionDescriptions(Console.Out);
            return;
        }

        InitialiseOpenVR();

        Console.WriteLine($"OSC destination - {dest}:{port}");
        osc = new OscClient(dest, port);


        while (true)
        {
            vrSystem.GetDeviceToAbsoluteTrackingPose(ETrackingUniverseOrigin.TrackingUniverseStanding, 0.0f, poseArray);

            for (uint i = 0; i < poseArray.Length; i++)
            {
                var item = poseArray[i];
                if (item.bDeviceIsConnected)
                {
                    if (oldposeArray[i].bDeviceIsConnected == false)
                    {
                        Console.WriteLine($"Device {i} connected, finding serial");

                        serialArray[i] = "";

                        ETrackedPropertyError err = ETrackedPropertyError.TrackedProp_Success;
                        sb.Clear();
                        vrSystem.GetStringTrackedDeviceProperty(i, ETrackedDeviceProperty.Prop_SerialNumber_String, sb, 500, ref err);
                        string serial = sb.ToString();

                        if (err != ETrackedPropertyError.TrackedProp_Success || serialArray.Contains(serial) || serial == "")
                        {
                            serial = $"Index{i}{vrSystem.GetTrackedDeviceClass(i).ToString()}";
                        }

                        Console.WriteLine($"Serial: {serial}");
                        serialArray[i] = serial;
                    }

                    if (item.bPoseIsValid)
                    {
                        var mat = item.mDeviceToAbsoluteTracking;

                        Vector3 p = mat.GetPosition();
                        Quaternion q = mat.GetRotation();

                        count++;

                        try
                        {
                            osc.Send("/VMC/Ext/Tra/Pos", serialArray[i], p.X, p.Y, p.Z, q.X, q.Y, q.Z, q.W);
                            if (verbose > 0){
                                Console.WriteLine($"{serialArray[i]} {p} {q}");
                            }
                        }
                        catch (System.Net.Sockets.SocketException e)
                        {
                            if (count % (rate*10) == 0){
                                Console.WriteLine($"SocketException: {e.Message}");
                            }
                        }

                    }
                }
            }

            var temp = oldposeArray;
            oldposeArray = poseArray;
            poseArray = temp;

            while (Console.KeyAvailable)
            {
                var key = Console.ReadKey(true);
                switch (key.Key)
                {
                    case ConsoleKey.Escape:
                        OpenVR.Shutdown();
                        vrSystem = null;
                        osc.Dispose();
                        Environment.Exit(0);
                        break;
                    default:
                        break;
                }
            }


            System.Threading.Thread.Sleep(Math.Max(1000 / rate, 10));
        }
    }
}
