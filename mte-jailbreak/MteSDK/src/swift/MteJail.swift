// The MIT License (MIT)
//
// Copyright (c) Eclypses, Inc.
//
// All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Imports when creating a Swift Package Manager package.
#if MTE_SWIFT_PACKAGE_MANAGER
import Mte
import Core
#endif

// Class MteJail
//
// This is a helper to mutate the nonce according to the chosen algorithm.
public class MteJail : MteNonceCallback {
  // This defines the jailbreak detection algorithm to use or simulate.
  public enum Algo : String, CaseIterable {
    // No choice made.
    case aNone

    // Android ARM32 device.
    case aAndroidArm32Dev

    // Android ARM64 device.
    case aAndroidArm64Dev

    // Android x86 simulator.
    case aAndroidX86Sim

    // Android x86_64 simulator.
    case aAndroidX86_64Sim

    // iOS ARM64 device.
    case aIosArm64Dev

    // iOS x86_64 simulator.
    case aIosX86_64Sim

    // Initialize based on the OS, architecture, and device/simulator.
    public init() {
#if os(iOS) && targetEnvironment(simulator) && arch(x86_64)
      self = .aIosX86_64Sim
#elseif os(iOS) && arch(arm64)
      self = .aIosArm64Dev
#else
      self = .aNone
#endif
    }

    // Return the integer value.
    func asInt() -> Int {
      return Algo.allCases.firstIndex(of: self)!
    }
  }

  // Set the jailbreak algorithm to pair with. Defaults to Algo.aIosX86_64Sim
  // when building for the x86_64 simulator target, Algo.aIosArm64Dev when
  // building for the ARM64 device target, or Algo.aNone otherwise.
  public func setAlgo(_ algo: Algo) {
    myAlgo = algo
  }

  // Set the nonce seed.
  public func setNonceSeed(_ seed: UInt64) {
    for i in 0..<mySeed.count {
      mySeed[i] = UInt8(UInt64(seed >> (i * 8)) & 0xFF)
    }
  }

  // The nonce callback.
  public func nonceCallback(_ minLength: Int,
                            _ maxLength: Int,
                            _ nonce: inout [UInt8],
                            _ nBytes: inout Int) {
    let sBytes = UInt32(mySeed.count)
    mySeed.withUnsafeBytes { s in
      nonce.withUnsafeMutableBytes { n in
        var nb = UInt32(nBytes)
        switch myAlgo {
          case .aNone:
            let amt = min(Int(sBytes), maxLength)
            n.baseAddress!.assumingMemoryBound(to: UInt8.self).assign(from:
              s.baseAddress!.assumingMemoryBound(to: UInt8.self), count: amt)
            nb = UInt32(max(amt, minLength))

          case .aAndroidArm32Dev:
            mte_wrap_jail_n_cb_android_arm32_d(s.baseAddress,
                                               sBytes,
                                               UInt32(minLength),
                                               UInt32(maxLength),
                                               n.baseAddress,
                                               &nb)

          case .aAndroidArm64Dev:
            mte_wrap_jail_n_cb_android_arm64_d(s.baseAddress,
                                               sBytes,
                                               UInt32(minLength),
                                               UInt32(maxLength),
                                               n.baseAddress,
                                               &nb)

          case .aAndroidX86Sim:
            mte_wrap_jail_n_cb_android_x86_s(s.baseAddress,
                                             sBytes,
                                             UInt32(minLength),
                                             UInt32(maxLength),
                                             n.baseAddress,
                                             &nb)

          case .aAndroidX86_64Sim:
            mte_wrap_jail_n_cb_android_x86_64_s(s.baseAddress,
                                                sBytes,
                                                UInt32(minLength),
                                                UInt32(maxLength),
                                                n.baseAddress,
                                                &nb)

          case .aIosArm64Dev:
            mte_wrap_jail_n_cb_ios_arm64_d(s.baseAddress,
                                           sBytes,
                                           UInt32(minLength),
                                           UInt32(maxLength),
                                           n.baseAddress,
                                           &nb)

          case .aIosX86_64Sim:
            mte_wrap_jail_n_cb_ios_x86_64_s(s.baseAddress,
                                            sBytes,
                                            UInt32(minLength),
                                            UInt32(maxLength),
                                            n.baseAddress,
                                            &nb)
        }
        nBytes = Int(nb)
      }
    }
  }

  // Jailbreak algorithm.
  private var myAlgo = Algo()

  // Nonce seed.
  private var mySeed = [UInt8](repeating: 0, count: MemoryLayout<UInt64>.size)
}

